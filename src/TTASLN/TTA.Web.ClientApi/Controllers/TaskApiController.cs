using System.Net.Mime;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.ClientApi.Options;

namespace TTA.Web.ClientApi.Controllers;

[Route("tasks-api")]
[Produces(MediaTypeNames.Application.Json)]
[ApiController]
public class TaskApiController : ControllerBase
{
    private readonly ILogger<TaskApiController> logger;
    private readonly IWorkTaskRepository workTaskRepository;
    private readonly IWorkTaskCommentRepository workTaskCommentRepository;
    private readonly IUserRepository userRepository;
    private readonly GeneralWebOptions webOptions;

    public TaskApiController(ILogger<TaskApiController> logger,
        IWorkTaskRepository workTaskRepository,
        IWorkTaskCommentRepository workTaskCommentRepository,
        IUserRepository userRepository,
        IOptions<GeneralWebOptions> webOptionsValue)
    {
        this.logger = logger;
        webOptions = webOptionsValue.Value;
        this.workTaskRepository = workTaskRepository;
        this.workTaskCommentRepository = workTaskCommentRepository;
        this.userRepository = userRepository;
    }

    [HttpGet]
    [Route("active/{userId}")]
    [Produces(typeof(IEnumerable<WorkTask>))]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetActiveTasksForUser(string userId)
    {
        if (string.IsNullOrEmpty(userId))
        {
            logger.LogWarning("User is not specified, returning bad request at {DateCreated}", DateTime.Now);
            return BadRequest("Specify user identification in order to get items");
        }

        try
        {
            var workTasks = await workTaskRepository.SearchCompletedAsync(1, webOptions.PageCount, string.Empty);
            var userWorkTasks = workTasks.Where(currentWorkTask => currentWorkTask.User.TTAUserId == userId);
            logger.LogInformation("Received {NumberOfActiveTasks} active tasks for user {UserId}",
                userWorkTasks.Count(),
                userId);
            return Ok(userWorkTasks);
        }
        catch (Exception e)
        {
            logger.LogError(e.Message);
            return BadRequest($"Data was not retrieved based on {userId}");
        }
    }

    [HttpGet]
    [Route("search/{userId}/{query}")]
    [Produces(typeof(IEnumerable<WorkTask>))]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetTasksForUser(string userId, string query)
    {
        if (string.IsNullOrEmpty(userId))
        {
            logger.LogWarning("User is not specified, returning bad request at {DateCreated}", DateTime.Now);
            return BadRequest("Specify user identification in order to get items");
        }

        var workTasks = await workTaskRepository.WorkTasksForUserAsync(userId, 1, webOptions.PageCount, query);
        logger.LogInformation("Received {NumberOfActiveTasks} tasks for user {UserId}", workTasks.Count,
            userId);
        return Ok(workTasks.ToList());
    }

    [Route("pdf/{userId}")]
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> DownloadPdfAsync(string userId)
    {
        if (string.IsNullOrEmpty(userId))
        {
            logger.LogWarning("User is not specified, returning bad request at {DateCreated}", DateTime.Now);
            return BadRequest("Specify user identification in order to get PDF");
        }

        logger.LogInformation("Download PDF for user {UserId} called at {DateLoaded}", userId, DateTime.Now);
        var workTasks = await workTaskRepository.WorkTasksForUserAsync(userId);
        var user = await userRepository.DetailsAsync(userId);
        logger.LogInformation("Received {NumberOfActiveTasks} tasks for user {UserId}", workTasks.Count,
            user.FullName);
        var generatePdf = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(20));

                    page.Header()
                        .Text($"Work tasks for user {user.FullName}!")
                        .SemiBold().FontSize(36).FontColor(Colors.Blue.Medium);

                    page.Content()
                        .PaddingVertical(1, Unit.Centimetre)
                        .Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.RelativeColumn(3);
                                columns.RelativeColumn();
                                columns.RelativeColumn();
                                columns.RelativeColumn();
                            });
                            table.Header(header =>
                            {
                                header.Cell().Element(CellStyle).Text("Description");
                                header.Cell().Element(CellStyle).AlignRight().Text("Started");
                                header.Cell().Element(CellStyle).AlignRight().Text("Ended");
                                header.Cell().Element(CellStyle).AlignRight().Text("Category");

                                static IContainer CellStyle(IContainer container) =>
                                    container.DefaultTextStyle(x => x.SemiBold()).PaddingVertical(5).BorderBottom(1)
                                        .BorderColor(Colors.Black);
                            });
                            foreach (var item in workTasks)
                            {
                                table.Cell().Element(CellStyle)
                                    .Text(item.Description)
                                    .WrapAnywhere();
                                table.Cell().Element(CellStyle)
                                    .AlignCenter()
                                    .Text(item.Start.ToShortDateString());
                                table.Cell().Element(CellStyle)
                                    .Text(item.End.ToShortDateString());
                                table.Cell().Element(CellStyle).AlignCenter()
                                    .Text(item.Category.Name);

                                static IContainer CellStyle(IContainer container) =>
                                    container.BorderBottom(1).BorderColor(Colors.Grey.Lighten2)
                                        .PaddingVertical(5);
                            }
                        });
                    page.Footer()
                        .AlignCenter()
                        .Text(x =>
                        {
                            x.Span("Page ");
                            x.CurrentPageNumber();
                        });
                });
            })
            .GeneratePdf();
        return File(generatePdf, "application/pdf");
    }

    [Route("complete")]
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CompleteTaskAsync([FromBody] string workTaskId)
    {
        logger.LogInformation("Worktask with {WorkTaskId} called at {DateLoaded}", workTaskId, DateTime.Now);
        try
        {
            var completed = await workTaskRepository.CompleteTaskAsync(workTaskId);
            return Ok(completed);
        }
        catch (Exception e)
        {
            logger.LogError(e.Message);
            return BadRequest($"Error has happened with completing task {workTaskId}");
        }
    }

    [Route("comment")]
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> AddCommentAsync(WorkTaskComment workTaskComment)
    {
        logger.LogInformation("Adding comment to worktask with {WorkTaskId} called at {DateLoaded}",
            workTaskComment.AssignedTask.WorkTaskId, DateTime.Now);
        try
        {
            workTaskComment.StartDate = DateTime.Now;
            var taskComment = await workTaskCommentRepository.InsertAsync(workTaskComment);
            return Ok(taskComment);
        }
        catch (Exception e)
        {
            logger.LogError(e.Message);
            return BadRequest(
                $"Error has happened with adding comment to task {workTaskComment.AssignedTask.WorkTaskId}");
        }
    }
}