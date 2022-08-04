using Microsoft.AspNetCore.Mvc;
using TTA.Interfaces;

namespace TTA.Web.Controllers;

[Route("tasks-api")]
[ApiController]
public class TaskApiController : ControllerBase
{
    private readonly ILogger<TaskApiController> logger;
    private readonly IWorkTaskRepository workTaskRepository;

    public TaskApiController(ILogger<TaskApiController> logger, IWorkTaskRepository workTaskRepository)
    {
        this.logger = logger;
        this.workTaskRepository = workTaskRepository;
    }

    [Route("complete-task")]
    [HttpPost]
    public async Task<bool> CompleteTaskAsync([FromBody] string workTaskId)
    {
        logger.LogInformation("Worktask with {WorkTaskId} called at {DateLoaded}", workTaskId, DateTime.Now);
        return await workTaskRepository.CompleteTaskAsync(workTaskId);
    }
}