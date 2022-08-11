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

    public async Task<IActionResult> OnGetAsync(int? pageNumber)
    {
        var pageCount = pageNumber ?? 1;
        logger.LogInformation("Task search page loaded {DateStarted}", DateTime.Now);
        WorkTasks = await workTaskRepository.SearchAsync(pageCount, webOptions.PageCount, true, Query);
        logger.LogInformation("Loaded {ItemCount} out of {AllCount} with {Query}", WorkTasks.Count,
            WorkTasks.TotalPages, Query);

        if (!Request.IsHtmx()) return Page();
        
        //Response.Htmx(h => h.Push(Request.GetEncodedUrl()));
        return Partial("_WorkTasksList", WorkTasks);
    }
    
    [BindProperty(SupportsGet = true)]
    public string Query { get; set; }
    [BindProperty] public PaginatedList<WorkTask> WorkTasks { get; set; }
}