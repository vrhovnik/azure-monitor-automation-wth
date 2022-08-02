using TTA.Models;

namespace TTA.Interfaces
{
    public interface IUserRepository : IDataRepository<TTAUser>
    {
        Task<TTAUser> LoginAsync(string username, string password);
        Task<TTAUser> FindAsync(string email);
    }
}