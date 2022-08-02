using Microsoft.AspNetCore.Mvc.RazorPages;

namespace TTA.Web.Pages;

public class IndexPageModel : PageModel
{
    private readonly ILogger<IndexPageModel> logger;

    public IndexPageModel(ILogger<IndexPageModel> logger) => this.logger = logger;

    public void OnGet() => logger.LogInformation("Main info page has been loaded at {CurrentDateTime}", DateTime.Now);
}