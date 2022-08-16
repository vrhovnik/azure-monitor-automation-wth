using System.Net.Http.Json;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Serilog;
using TTA.Core;
using TTA.Models;

namespace TTA.Client.Win.Services;

public class WorkTaskApiHelper : BaseTaskApiHelper
{
    public WorkTaskApiHelper(ILogger logger) : base(logger)
    {
    }
    
    public async Task<PaginatedList<WorkTask>> GetTaskForUsersAsync(string userId, string query)
    {
        var response = await Client.GetAsync($"tasks-api/search/{userId}/{query}");
        if (!response.IsSuccessStatusCode) return new PaginatedList<WorkTask>();

        var workTaskJson = await response.Content.ReadAsStringAsync();
        return JsonConvert.DeserializeObject<PaginatedList<WorkTask>>(workTaskJson);
    }

    public async Task<WorkTaskComment> AddCommentAsync(WorkTaskComment taskComment)
    {
        var response = await Client.PostAsJsonAsync("task-api/comment", taskComment);
        if (!response.IsSuccessStatusCode) return null;

        var addedComment = await response.Content.ReadAsStringAsync();
        return JsonConvert.DeserializeObject<WorkTaskComment>(addedComment);
    }
}