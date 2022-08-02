using Htmx;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Options;
using TTA.Core;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.Base;
using TTA.Web.Options;

namespace TTA.Web.Pages.User;

//[Authorize]
public class DashboardPageModel : BasePageModel
{
    private readonly ILogger<DashboardPageModel> logger;
    private readonly IProfileSettingsService profileSettingsService;
    private readonly IWorkTaskRepository workTaskRepository;
    private GeneralWebOptions generalWebOptions;

    public DashboardPageModel(ILogger<DashboardPageModel> logger,
        IProfileSettingsService profileSettingsService, IWorkTaskRepository workTaskRepository,
        IOptions<GeneralWebOptions> webSettingsValue)
    {
        this.logger = logger;
        generalWebOptions = webSettingsValue.Value;
        this.profileSettingsService = profileSettingsService;
        this.workTaskRepository = workTaskRepository;
    }

    public async Task<IActionResult> OnGetAsync(int? pageNumber, string query)
    {
        var currentPageNumber = pageNumber ?? 1;
        var profileName = User.Identity.Name;
        logger.LogInformation("Loading dashboard for user {User} - starting at {DateStart}", profileName, DateTime.Now);
        var id = profileName.GetUniqueValue();
        ProfileSettings = await profileSettingsService.GetAsync(id);
        logger.LogInformation("Got profile for {UniqueSettingsId} - ended at {DateEnd}", id, DateTime.Now);

        UserTasks = await workTaskRepository.WorkTasksForUserAsync(profileName, currentPageNumber,
            generalWebOptions.PageCount, query);
        logger.LogInformation("Loaded {UserTaskNumber} work tasks for user with {Query}", UserTasks.TotalPages, query);

        if (Request.IsHtmx()) return Partial("_WorkTasksList", UserTasks);
        
        return Page();
    }

    [BindProperty] public TTAUserSettings ProfileSettings { get; set; }
    [BindProperty] public PaginatedList<WorkTask> UserTasks { get; set; }
}