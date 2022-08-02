using System.Data.SqlClient;
using Dapper;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;

namespace TTA.SQL;

public class TTAUserRepository : BaseRepository<TTAUser>, IUserRepository
{
    public TTAUserRepository(string connectionString) : base(connectionString)
    {
    }

    public async Task<TTAUser> LoginAsync(string username, string password)
    {
        await using var connection = new SqlConnection(connectionString);
        var item = await connection.QuerySingleOrDefaultAsync<TTAUser>(
            "SELECT U.* " +
            "FROM [TTAUsers] U WHERE U.Email=@username", new {username});

        if (item == null) return null;

        item = await DetailsAsync(item.TTAUserId);

        return PasswordHash.ValidateHash(password, item.Password) ? item : null;
    }

    public async Task<TTAUser> FindAsync(string email)
    {
        await using var connection = new SqlConnection(connectionString);
        var virtuUsers = await connection.QueryAsync<TTAUser>(
            "SELECT U.* " +
            "FROM [TTAUsers] U WHERE U.Email=@email", new {email});
        return virtuUsers.Any() ? virtuUsers.ElementAt(0) : null;
    }
}