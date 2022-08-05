using Htmx;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.Base;
using TTA.Web.Options;

namespace TTA.Web.Pages.Tasks;

public class IndexPageModel : BasePageModel
{
    private readonly ILogger<IndexPageModel> logger;
    private readonly IWorkTaskRepository workTaskRepository;
    private readonly IUserDataContext userDataContext;
    private GeneralWebOptions? webOptions;

    public IndexPageModel(ILogger<IndexPageModel> logger,
        IWorkTaskRepository workTaskRepository,
        IOptions<GeneralWebOptions> webSettingsValue,
        IUserDataContext userDataContext)
    {
        this.logger = logger;
        webOptions = webSettingsValue.Value;
        this.workTaskRepository = workTaskRepository;
        this.userDataContext = userDataContext;
    }

    public async Task<IActionResult> OnGetAsync(int? page, string query)
    {
        int pageCount = page ?? 1;
        logger.LogInformation("Task search page loaded {DateStarted}", DateTime.Now);
        bool isPublic = User.Identity is { IsAuthenticated: false };
        WorkTasks = await workTaskRepository.SearchAsync(pageCount, webOptions.PageCount, isPublic, query);
        logger.LogInformation("Loaded {ItemCount} out of {AllCount} with {Query}", WorkTasks.Count,
            WorkTasks.TotalPages, query);

        if (Request.IsHtmx()) return Partial("_WorkTasksList", WorkTasks);

        return Page();
    }

    [BindProperty] public PaginatedList<WorkTask> WorkTasks { get; set; }
}