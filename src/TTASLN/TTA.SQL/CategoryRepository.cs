using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL
{
    public class CategoryRepository : BaseRepository<Category>, ICategoryRepository
    {
        public CategoryRepository(string connectionString) : base(connectionString)
        {
        }

    }
}