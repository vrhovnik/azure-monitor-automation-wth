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
        throw new NotImplementedException();
    }
}