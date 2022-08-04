using TTA.Models;

namespace TTA.Interfaces;

public interface IWorkTaskCommentRepository : IDataRepository<WorkTaskComment>
{
    public Task<List<WorkTaskComment>> GetCommentsForWorkTaskAsync(string workTaskId);
}