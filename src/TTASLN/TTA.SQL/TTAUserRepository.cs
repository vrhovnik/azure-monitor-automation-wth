using System.Data.SqlClient;
using Dapper;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class TTAUserRepository : BaseRepository<TTAUser>, IUserRepository
{
    public TTAUserRepository(string connectionString) : base(connectionString)
    {
    }

    public override async Task<List<TTAUser>> GetAsync()
    {
        await using var connection = new SqlConnection(connectionString);
        var sql = "SELECT U.UserId as TTAUserId, U.FullName, U.Email, U.Password FROM Users U";
        var ttaUsers = await connection.QueryAsync<TTAUser>(sql);
        return ttaUsers.ToList();
    }

    public override async Task<TTAUser> InsertAsync(TTAUser entity)
    {
        await using var connection = new SqlConnection(connectionString);
        entity.Password = PasswordHash.CreateHash(entity.Password);
        var item = await connection.ExecuteScalarAsync(
            $"INSERT INTO Users(FullName,Email,Password)VALUES(@{nameof(entity.FullName)},@{nameof(entity.Email)},@{nameof(entity.Password)});SELECT CAST(SCOPE_IDENTITY() as bigint)",
            entity);
        var userId = Convert.ToInt64(item);
        entity.TTAUserId = userId.ToString();

        //add profile data
        await connection.ExecuteAsync(
            $"INSERT INTO UserSetting(EmailNotification, UserId)VALUES(@{nameof(entity.UserSettings.EmailNotification)},@userId)",
            new { EmailNotification = entity.UserSettings.EmailNotification, userId });

        return entity;
    }

    public override async Task<TTAUser> DetailsAsync(string entityId)
    {
        await using var connection = new SqlConnection(connectionString);
        var query = "SELECT U.UserId as TTAUserId, U.FullName, U.Email, U.Password FROM Users U WHERE U.UserId=@entityId;" +
                    "SELECT T.* FROM WorkTasks T JOIN WorkTask2Tags FF on FF.WorkTaskId=T.WorkTaskId WHERE T.UserId=@entityId;" +
                    "SELECT F.* FROM UserSetting F WHERE F.UserId=@entityId;";

        var result = await connection.QueryMultipleAsync(query, new { entityId });
        var ttaUser = await result.ReadSingleAsync<TTAUser>();
        ttaUser.Tasks = result.Read<WorkTask>().AsList();
        ttaUser.UserSettings = await result.ReadSingleAsync<TTAUserSettings>();
        return ttaUser;
    }

    public async Task<TTAUser> LoginAsync(string username, string password)
    {
        await using var connection = new SqlConnection(connectionString);
        var item = await connection.QuerySingleOrDefaultAsync<TTAUser>(
            "SELECT U.UserId as TTAUserId, U.FullName, U.Email FROM Users U WHERE U.Email=@username", new { username });

        if (item == null) return null;

        item = await DetailsAsync(item.TTAUserId);

        return PasswordHash.ValidateHash(password, item.Password) ? item : null;
    }

    public async Task<TTAUser> FindAsync(string email)
    {
        await using var connection = new SqlConnection(connectionString);
        var ttaUsers = await connection.QueryAsync<TTAUser>(
            "SELECT U.UserId as TTAUserId, U.FullName, U.Email " +
            "FROM Users U WHERE U.Email=@email", new { email });
        return ttaUsers.Any() ? ttaUsers.ElementAt(0) : null;
    }
}