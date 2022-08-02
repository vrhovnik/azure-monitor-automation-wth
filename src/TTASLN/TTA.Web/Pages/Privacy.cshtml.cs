using Microsoft.AspNetCore.Mvc.RazorPages;

namespace TTA.Web.Pages;

public class PrivacyPageModel : PageModel
{
    private readonly ILogger<PrivacyPageModel> logger;

    public PrivacyPageModel(ILogger<PrivacyPageModel> logger) => this.logger = logger;

    public void OnGet() => logger.LogInformation("Privacy page was loaded at {CurrentDateTime}", DateTime.Now);
}