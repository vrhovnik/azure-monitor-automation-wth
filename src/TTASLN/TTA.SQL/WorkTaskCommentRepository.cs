using System.Data.SqlClient;
using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class WorkTaskCommentRepository : BaseRepository<WorkTaskComment>, IWorkTaskCommentRepository
{
    public WorkTaskCommentRepository(string connectionString) : base(connectionString)
    {
    }

    public async Task<List<WorkTaskComment>> GetCommentsForWorkTaskAsync(string workTaskId)
    {
        await using var connection = new SqlConnection(connectionString);
        throw new NotImplementedException();
    }
}