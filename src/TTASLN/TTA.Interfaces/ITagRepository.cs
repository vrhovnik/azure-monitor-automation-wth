using TTA.Models;

namespace TTA.Interfaces;

public interface ITagRepository : IDataRepository<Tag>
{
    public Task<List<Tag>> GetAllAsync();
}