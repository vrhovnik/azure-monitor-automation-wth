using Htmx;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.Base;
using TTA.Web.Options;

namespace TTA.Web.Pages.User;

[Authorize]
public class DashboardPageModel : BasePageModel
{
    private readonly ILogger<DashboardPageModel> logger;
    private readonly IProfileSettingsService profileSettingsService;
    private readonly IWorkTaskRepository workTaskRepository;
    private readonly IUserDataContext userDataContext;
    private GeneralWebOptions generalWebOptions;

    public DashboardPageModel(ILogger<DashboardPageModel> logger,
        IProfileSettingsService profileSettingsService,
        IWorkTaskRepository workTaskRepository,
        IOptions<GeneralWebOptions> webSettingsValue,
        IUserDataContext userDataContext)
    {
        this.logger = logger;
        generalWebOptions = webSettingsValue.Value;
        this.profileSettingsService = profileSettingsService;
        this.workTaskRepository = workTaskRepository;
        this.userDataContext = userDataContext;
    }

    public async Task<IActionResult> OnGetAsync(int? pageNumber, string query)
    {
        var currentPageNumber = pageNumber ?? 1;
        var userViewModel = userDataContext.GetCurrentUser();
        PdfDownloadUrl = $"{generalWebOptions.ClientApiUrl}/task-api/download-pdf/{userViewModel.UserId}";
        logger.LogInformation("Loading dashboard for user {User} - starting at {DateStart}", userViewModel.Fullname,
            DateTime.Now);

        var userId = userViewModel.UserId;
        ProfileSettings = await profileSettingsService.GetAsync(userId);
        logger.LogInformation("Got profile for {UniqueSettingsId} - ended at {DateEnd}", userId, DateTime.Now);

        UserTasks = await workTaskRepository.WorkTasksForUserAsync(userId, currentPageNumber,
            generalWebOptions.PageCount, query);
        logger.LogInformation("Loaded {UserTaskNumber} work tasks for user with {Query}", UserTasks.TotalPages, query);

        if (!Request.IsHtmx()) return Page();
        
        //Response.Htmx(h => h.Push(Request.GetEncodedUrl()));
        return Partial("_WorkTasksList", UserTasks);
    }

    [BindProperty] public string PdfDownloadUrl { get; set; }
    [BindProperty] public TTAUserSettings ProfileSettings { get; set; }
    [BindProperty] public PaginatedList<WorkTask> UserTasks { get; set; }
}