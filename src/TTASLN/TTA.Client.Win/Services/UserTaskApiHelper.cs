using System.Collections.Generic;
using System.Threading.Tasks;
using Newtonsoft.Json;
using TTA.Models;

namespace TTA.Client.Win.Services;

public class UserTaskApiHelper : BaseTaskApiHelper
{
    public async Task<List<TTAUser>> GetUsersAsync()
    {
        var response = await Client.GetAsync("user-api/all");
        if (!response.IsSuccessStatusCode) return new List<TTAUser>();
        
        var usersInJson = await response.Content.ReadAsStringAsync();
        return JsonConvert.DeserializeObject<List<TTAUser>>(usersInJson);
    }
}