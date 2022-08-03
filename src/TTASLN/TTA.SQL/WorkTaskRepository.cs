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

    public async Task<PaginatedList<WorkTask>> WorkTasksForUserAsync(string userIdentificator,
        int pageIndex = 1, int pageSize = 10, string query = "")
    {
        await using var connection = new SqlConnection(connectionString);
        var sqlQuery =
            "SELECT T.WorkTaskId,T.StartDate as [Start], T.EndDate as [End], T.Description, T.IsPublic, T.CategoryId, C.Name  "+
            " FROM WorkTasks T JOIN WorkTask2Tags FF on FF.WorkTaskId=T.WorkTaskId "+
            " JOIN Category C on C.CategoryId=T.CategoryId "+
            " WHERE T.UserId=@userIdentificator";

        if (!string.IsNullOrEmpty(query)) sqlQuery += $" AND T.Description LIKE '%{query}%'";

        var result = await connection.QueryAsync<WorkTask>(sqlQuery, new { userIdentificator });
        return new PaginatedList<WorkTask>(result, result.Count(), pageIndex, pageSize, query);
    }
}