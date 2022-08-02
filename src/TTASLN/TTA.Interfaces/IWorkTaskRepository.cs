using TTA.Core;
using TTA.Models;

namespace TTA.Interfaces;

public interface IWorkTaskRepository : IDataRepository<WorkTask>
{
    public Task<PaginatedList<WorkTask>> WorkTasksForUserAsync(string userIdentificator, 
        int pageIndex = 1, 
        int pageSize = 10,
        string query = "");
}