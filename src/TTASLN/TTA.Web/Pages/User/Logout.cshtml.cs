using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace TTA.Web.Pages.User;

public class LogoutPageModel : PageModel
{
    private readonly ILogger<LogoutPageModel> logger;

    public LogoutPageModel(ILogger<LogoutPageModel> logger) => this.logger = logger;

    public async Task OnGetAsync()
    {
        logger.LogInformation("Logged out page loaded at {DateLoaded}.", DateTime.Now);
        await HttpContext.SignOutAsync();
    }
}