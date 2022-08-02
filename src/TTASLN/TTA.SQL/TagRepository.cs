using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class TagRepository : BaseRepository<Tag>, ITagRepository
{
    public TagRepository(string connectionString) : base(connectionString)
    {
    }
}