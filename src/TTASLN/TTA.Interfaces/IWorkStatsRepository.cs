using TTA.Core;
using TTA.Models;

namespace TTA.Interfaces;

public interface IWorkStatsRepository : IDataRepository<WorkTaskStats>
{
    PaginatedList<WorkTask> GetStatsAsync(DateTime from, DateTime to);
}