using TTA.Models;

namespace TTA.Interfaces;

public interface ICategoryRepository : IDataRepository<Category>
{
        public Task<List<Category>> GetAllAsync();
}