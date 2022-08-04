using System.Data.SqlClient;
using Dapper;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class WorkTaskRepository : BaseRepository<WorkTask>, IWorkTaskRepository
{
    public WorkTaskRepository(string connectionString) : base(connectionString)
    {
    }

    public override async Task<WorkTask> InsertAsync(WorkTask entity)
    {
        await using var connection = new SqlConnection(connectionString);
        var item = await connection.ExecuteScalarAsync(
            $"INSERT INTO WorkTasks(Description,CategoryId,StartDate, EndDate,UserId,IsPublic)VALUES" +
            $"(@{nameof(entity.Description)},@{nameof(entity.Category.CategoryId)},@{nameof(entity.Start)},@{nameof(entity.End)},@{nameof(entity.User.TTAUserId)},@{nameof(entity.IsPublic)});" +
            "SELECT CAST(SCOPE_IDENTITY() as bigint)",
            entity);

        var workTaskId = Convert.ToInt64(item);
        entity.WorkTaskId = workTaskId.ToString();

        foreach (var tag in entity.Tags)
        {
            await connection.ExecuteAsync("INSERT INTO WorkTask2Tags(WorkTaskId,TagName)VALUES(@workTaskId,@tag)",
                new { workTaskId, tag });
        }

        return entity;
    }

    public override async Task<bool> UpdateAsync(WorkTask entity)
    {
        await using var connection = new SqlConnection(connectionString);
        var item = await connection.ExecuteAsync(
            $"UPDATE WorkTasks SET Description=@{nameof(entity.Description)},CategoryId=@{nameof(entity.Description)},StartDate=@{nameof(entity.Start)}," +
            $"EndDate=@{nameof(entity.End)},UserId=@{nameof(entity.User.TTAUserId)},IsPublic=@{nameof(entity.IsPublic)}) WHERE WorkTaskId=@{nameof(entity.WorkTaskId)}",
            entity);

        if (item < 0) return false;

        string workTaskId = entity.WorkTaskId;
        item = await connection.ExecuteAsync("DELETE FROM WorkTask2Tags WHERE WHERE WorkTaskId=@workTaskId",
            new { workTaskId });

        if (item > 0)
        {
            foreach (var tag in entity.Tags)
            {
                await connection.ExecuteAsync("INSERT INTO WorkTask2Tags(WorkTaskId,TagName)VALUES(@workTaskId,@tag)",
                    new { workTaskId, tag });
            }
        }

        return true;
    }

    public async Task<PaginatedList<WorkTask>> WorkTasksForUserAsync(string userIdentificator,
        int pageIndex = 1, int pageSize = 10, string query = "")
    {
        await using var connection = new SqlConnection(connectionString);
        var sqlQuery =
            "SELECT T.WorkTaskId,T.StartDate as [Start], T.EndDate as [End], T.Description, T.IsPublic, T.CategoryId, C.Name  " +
            " FROM WorkTasks T JOIN WorkTask2Tags FF on FF.WorkTaskId=T.WorkTaskId " +
            " JOIN Category C on C.CategoryId=T.CategoryId " +
            " WHERE T.UserId=@userIdentificator";

        if (!string.IsNullOrEmpty(query)) sqlQuery += $" AND T.Description LIKE '%{query}%'";

        var result = await connection.QueryAsync<WorkTask>(sqlQuery, new { userIdentificator });
        return new PaginatedList<WorkTask>(result, result.Count(), pageIndex, pageSize, query);
    }

    public async Task<bool> CompleteTaskAsync(string workTaskId)
    {
        await using var connection = new SqlConnection(connectionString);
        var sqlQuery =
            "UPDATE WorkTasks SET EndDate=@CURRENT_DATE WHERE WorkTaskId=@workTaskId";
        return await connection.ExecuteAsync(sqlQuery, new { workTaskId }) > 0;
    }
}