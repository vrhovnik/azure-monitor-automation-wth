using Microsoft.AspNetCore.Mvc;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using TTA.Interfaces;

namespace TTA.Web.Controllers;

[Route("tasks-api")]
[ApiController]
public class TaskApiController : ControllerBase
{
    private readonly ILogger<TaskApiController> logger;
    private readonly IWorkTaskRepository workTaskRepository;
    private readonly IUserRepository userRepository;

    public TaskApiController(ILogger<TaskApiController> logger,
        IWorkTaskRepository workTaskRepository,
        IUserRepository userRepository)
    {
        this.logger = logger;
        this.workTaskRepository = workTaskRepository;
        this.userRepository = userRepository;
    }

    [Route("download-pdf-for-user/{userId}")]
    [HttpGet]
    public async Task<IActionResult> DownloadPdfAsync(string userId)
    {
        logger.LogInformation("Download PDF for user {UserId} called at {DateLoaded}", userId, DateTime.Now);
        var workTasks = await workTaskRepository.WorkTasksForUserAsync(userId);
        var user = await userRepository.DetailsAsync(userId);
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
                                table.Cell().Element(CellStyle).Text(item.Description);
                                table.Cell().Element(CellStyle).AlignRight().Text(item.Start);
                                table.Cell().Element(CellStyle).AlignRight().Text(item.End);
                                table.Cell().Element(CellStyle).AlignRight().Text(item.Category.Name);

                                static IContainer CellStyle(IContainer container) =>
                                    container.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(5);
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

    [Route("complete-task")]
    [HttpPost]
    public async Task<bool> CompleteTaskAsync([FromBody] string workTaskId)
    {
        logger.LogInformation("Worktask with {WorkTaskId} called at {DateLoaded}", workTaskId, DateTime.Now);
        return await workTaskRepository.CompleteTaskAsync(workTaskId);
    }
}