using TTA.Core;
using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class WorkTaskStatsRepository : BaseRepository<WorkTaskStats>, IWorkStatsRepository
{
    public WorkTaskStatsRepository(string connectionString) : base(connectionString)
    {
    }

    public PaginatedList<WorkTask> GetStatsAsync(DateTime from, DateTime to)
    {
        throw new NotImplementedException();
    }
}