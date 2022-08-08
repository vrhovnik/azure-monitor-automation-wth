using System.Data;
using System.Data.SqlClient;
using Bogus;
using Dapper;
using Spectre.Console;
using TTA.Models;

AnsiConsole.Write(new FigletText("Data generator for TTA demo app").Centered().Color(Color.Red));
var sqlConn = Environment.GetEnvironmentVariable("SQL_CONNECTION_STRING");
if (string.IsNullOrEmpty(sqlConn))
    sqlConn = @"Data Source=(LocalDb)\MSSQLLocalDB;Integrated Security=SSPI";

var sqlConnection = new SqlConnection(sqlConn);
try
{
    sqlConnection.Open();
    AnsiConsole.Write(
        new Markup($"[bold yellow]SQL connection to database[/] [red]{sqlConn}[/] [bold yellow]is opened.[/]"));
    AnsiConsole.WriteLine();
}
catch (Exception sqlCouldNotOpenException)
{
    AnsiConsole.WriteException(sqlCouldNotOpenException);
    return;
}

var dropIt =
    AnsiConsole.Confirm("Database will be recreated. Create backup before continuing. Are you sure to continue?");
if (!dropIt)
{
    AnsiConsole.WriteLine("Shutting down - run the app when backup is finished to be able to work with your data.");
    return;
}

var folderRoot = Environment.GetEnvironmentVariable("FOLDER_ROOT");
if (string.IsNullOrEmpty(folderRoot))
{
    folderRoot = AnsiConsole.Prompt(
        new TextPrompt<string>("Enter [green]folder root[/]")
            .PromptStyle("green")
            .ValidationErrorMessage(
                "[red]That's not a valid folder - check https://https://github.com/vrhovnik/azure-monitor-automation-wth[/]")
            .Validate(Directory.Exists));
}

AnsiConsole.WriteLine("You have entered the following:");
var path = new TextPath(folderRoot)
{
    RootStyle = new Style(foreground: Color.Red),
    SeparatorStyle = new Style(foreground: Color.Green),
    StemStyle = new Style(foreground: Color.Blue),
    LeafStyle = new Style(foreground: Color.Yellow)
};
AnsiConsole.Write(path);

var dbExistsCount =
    await sqlConnection.QuerySingleOrDefaultAsync<int>(
        "SELECT count(*) FROM master.dbo.sysdatabases WHERE name = 'TTADB'");
if (dbExistsCount > 0)
{
    AnsiConsole.Write(
        new Markup("[bold yellow]Database [/] [red]TTADB[/] [bold yellow] will be dropped."));
    try
    {
        var affectedRows = await sqlConnection.ExecuteAsync("DROP DATABASE TTADB");
        if (affectedRows == 0) throw new Exception("DROP was not successful, check logs");
    }
    catch (Exception dropException)
    {
        AnsiConsole.WriteException(dropException);
        return;
    }
}

//read script for init database
var initSqlDataScript = await File.ReadAllTextAsync(Path.Combine(folderRoot, "/scripts/SQL/0-init-database.sql"));

try
{
    var affectedRows = await sqlConnection.ExecuteAsync(initSqlDataScript);
    if (affectedRows == 0) throw new Exception("Creation of database and tables was not successful, check logs");
}
catch (Exception initException)
{
    AnsiConsole.WriteException(initException);
    return;
}

var defaultPassword = AnsiConsole.Prompt(
    new TextPrompt<string>("Enter DEFAULT [green]password[/]?")
        .PromptStyle("red")
        .Secret());

await AnsiConsole.Status()
    .AutoRefresh(false)
    .Spinner(Spinner.Known.Dots6)
    .SpinnerStyle(Style.Parse("green bold"))
    .StartAsync("Generating data started ...", async ctx =>
    {
        //0. make sure DB is created and structure populated
        ctx.Status("Getting tags and inserting tags ...");
        ctx.Refresh();

        //generate data with Bogus library
        //1. Tags
        var tags = await GetDataFromFileAsync("docs/tag.data");
        ctx.Status("Reading from file docs/tag.data");
        ctx.Refresh();

        var dtTags = new DataTable();
        dtTags.TableName = "Tags";
        dtTags.Columns.Add("TagName", typeof(string));

        foreach (var currentTag in tags)
        {
            ctx.Status($"Traversing through - current tag {currentTag} and preparing sql");
            var row = dtTags.NewRow();
            row["TagName"] = currentTag;
            dtTags.Rows.Add(row);
            ctx.Refresh();
        }

        if (await WriteBulkToDatabaseAsync(dtTags))
            ctx.Status("Inserted data to tags, continuting to categories");
        else
            ctx.Status("Check error log, tags were not inserted!");

        ctx.Refresh();

        //2. Categories
        var categories = await GetDataFromFileAsync("docs/categories.data");
        ctx.Status("Reading from file docs/categories.data");
        ctx.Refresh();

        var dtCategories = new DataTable();
        dtCategories.TableName = "Categories";
        dtCategories.Columns.Add("Name", typeof(string));

        foreach (var currentCategoryName in categories)
        {
            ctx.Status($"Traversing through - current category name {currentCategoryName} and preparing sql");
            var row = dtCategories.NewRow();
            row["Name"] = currentCategoryName;
            dtCategories.Rows.Add(row);
            ctx.Refresh();
        }

        await WriteBulkToDatabaseAsync(dtCategories);

        //3. Users
        var users = new Faker<TTAUser>()
            .RuleFor(currentUser => currentUser.FullName,
                (faker, _) => faker.Name.FirstName() + " " + faker.Name.LastName()
            ).RuleFor(u => u.Email, (f, u) => f.Internet.Email(u.FullName))
            .GenerateLazy(100);

        ctx.Status("Generated 100 users, adding to database");
        ctx.Refresh();

        var dtUsers = new DataTable();
        dtUsers.TableName = "Users";
        dtUsers.Columns.Add("FullName", typeof(string));
        dtUsers.Columns.Add("Email", typeof(string));
        dtUsers.Columns.Add("Password", typeof(string));

        foreach (var currentUser in users)
        {
            ctx.Status($"Traversing through - current user {currentUser.FullName} and preparing sql");
            var row = dtUsers.NewRow();
            row["FullName"] = currentUser.FullName;
            row["Email"] = currentUser.Email;
            row["Email"] = currentUser.Email;
            dtUsers.Rows.Add(row);
            ctx.Refresh();
        }

        await WriteBulkToDatabaseAsync(dtUsers);

        

        var usersInDatabase =
            await sqlConnection.QueryAsync<TTAUser>("SELECT UserId as TTAUserId,FullName, Email FROM Users");
        ctx.Status($"and received {usersInDatabase.Count()} users.");
        ctx.Refresh();
        
        var dtUserSettings = new DataTable();
        dtUserSettings.TableName = "UserSetting";
        dtUserSettings.Columns.Add("UserId", typeof(int));
        dtUserSettings.Columns.Add("EmailNotification", typeof(bool));

        foreach (var user in usersInDatabase)
        {
            ctx.Status($"Adding settings for user {user.FullName}");
            
            var row = dtUserSettings.NewRow();
            row["UserId"] = user.TTAUserId;
            row["EmailNotification"] = new Faker().Random.Bool();
            dtUserSettings.Rows.Add(row);
            ctx.Refresh();
        }
        
        await WriteBulkToDatabaseAsync(dtUserSettings);

        //4. WorkTasks
        var categoriesInDatabase = await sqlConnection.QueryAsync<Category>("SELECT CategoryId,Name FROM Categories");
        ctx.Status($"Added users and settings for that user. Continuing to insert work tasks. Received {categoriesInDatabase.Count()} categories");
        ctx.Refresh();
        
        var workTasks = new Faker<WorkTask>()
            .RuleFor(workTask => workTask.Description,
                (faker, _) => faker.Lorem.Paragraph(new Random().Next(3, 10)))
            .RuleFor(u => u.Start, (f, _) => f.Date.Recent(new Random().Next(3, 40)))
            .RuleFor(u => u.End, (f, _) => f.Date.Future(new Random().Next(3, 20)))
            .RuleFor(u => u.IsPublic, (f, _) => f.Random.Bool())
            .RuleFor(u => u.Category, (f, _) => f.PickRandom(categoriesInDatabase))
            .RuleFor(u => u.User, (f, _) => f.PickRandom(usersInDatabase))
            .GenerateLazy(100);

        var dtWorkTasks = new DataTable();
        dtWorkTasks.TableName = "WorkTasks";
        dtWorkTasks.Columns.Add("Description", typeof(string));
        dtWorkTasks.Columns.Add("StartDate", typeof(DateTime));
        dtWorkTasks.Columns.Add("EndDate", typeof(DateTime));
        dtWorkTasks.Columns.Add("IsPublic", typeof(bool));
        dtWorkTasks.Columns.Add("CategoryId", typeof(int));

        var taskCounter = 0;
        foreach (var workTask in workTasks)
        {
            ctx.Status($"Traversing through - current work task #{taskCounter++} and preparing sql");
            var row = dtWorkTasks.NewRow();
            row["Description"] = workTask.Description;
            row["StartDate"] = workTask.Start;
            row["EndDate"] = workTask.End;
            row["IsPublic"] = workTask.IsPublic;
            row["CategoryId"] = workTask.Category.CategoryId;
            row["UserId"] = workTask.User.TTAUserId;
            dtWorkTasks.Rows.Add(row);
            ctx.Refresh();
        }

        await WriteBulkToDatabaseAsync(dtWorkTasks);

        var dtWorkTasksTags = new DataTable();
        dtWorkTasksTags.TableName = "WorkTask2Tags";
        dtWorkTasksTags.Columns.Add("WorkTaskId", typeof(int));
        dtWorkTasksTags.Columns.Add("TagName", typeof(string));

        var dtWorkTasksComments = new DataTable();
        dtWorkTasksComments.TableName = "WorkTaskComments";
        dtWorkTasksComments.Columns.Add("WorkTaskId", typeof(int));
        dtWorkTasksComments.Columns.Add("UserId", typeof(int));
        dtWorkTasksComments.Columns.Add("Comment", typeof(string));
        dtWorkTasksComments.Columns.Add("StartDate", typeof(DateTime));

        var worktTasksInDatabase =
            await sqlConnection.QueryAsync<WorkTask>("SELECT WorkTaskId, Description FROM WorkTasks");
        ctx.Status($"Received {worktTasksInDatabase.Count()} work tasks.");
        ctx.Refresh();

        foreach (var workTask in worktTasksInDatabase)
        {
            ctx.Status($"Adding tags to tasks");
            ctx.Refresh();
           
            for (var currentCounter = 0; currentCounter < new Random().Next(2, 6); currentCounter++)
            {
                var row = dtWorkTasksTags.NewRow();
                row["WorkTaskId"] = workTask.WorkTaskId;
                var currentTag = new Faker<string>()
                    .Rules((faker, _) => faker.PickRandom(tags))
                    .Generate();
                row["TagName"] = currentTag;
                dtWorkTasksTags.Rows.Add(row);
                ctx.Status($"Adding tag {currentTag} to task {workTask.WorkTaskId}");
                ctx.Refresh();
                
                var currentRow = dtWorkTasksComments.NewRow();
                currentRow["WorkTaskId"] = workTask.WorkTaskId;
                currentRow["StartDate"] = new Faker().Date.Recent(new Random().Next(3, 24));
                currentRow["Comment"] = new Faker().Lorem.Paragraph(new Random().Next(2, 3));
                currentRow["UserId"] = new Faker().PickRandom(usersInDatabase).TTAUserId;
                dtWorkTasksComments.Rows.Add(currentRow);
                ctx.Status($"Adding comment to task {workTask.WorkTaskId}");
                ctx.Refresh();
            }
        }

        await WriteBulkToDatabaseAsync(dtWorkTasksTags);
        ctx.Status("Work tasks with tags added, adding random comments as well.");
        await WriteBulkToDatabaseAsync(dtWorkTasksComments);
    });

async Task<bool> WriteBulkToDatabaseAsync(DataTable dt)
{
    try
    {
        using var tagBulkInsert = new SqlBulkCopy(sqlConn);
        tagBulkInsert.DestinationTableName = dt.TableName;
        await tagBulkInsert.WriteToServerAsync(dt);
    }
    catch (Exception tagException)
    {
        AnsiConsole.WriteException(tagException);
        return false;
    }

    return true;
}

async Task<string[]> GetDataFromFileAsync(string filename, char delimiter = ',')
{
    var filePath = Path.Join(folderRoot, filename);
    var currentFile = await File.ReadAllTextAsync(filePath);
    return currentFile.Split(delimiter);
}

// public async Task SafeInsertMany(IEnumerable<string> userNames)
// {
//     using (var connection = new SqlConnection(ConnectionString))
//     {
//         var parameters = userNames.Select(u =>
//         {
//             var tempParams = new DynamicParameters();
//             tempParams.Add("@Name", u, DbType.String, ParameterDirection.Input);
//             return tempParams;
//         });
//
//         await connection.ExecuteAsync(
//             "INSERT INTO [Users] (Name, LastUpdatedAt) VALUES (@Name, getdate())",
//             parameters).ConfigureAwait(false);
//     }
// }