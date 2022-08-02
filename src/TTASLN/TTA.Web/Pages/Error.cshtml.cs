using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace TTA.Web.Pages;

[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
[IgnoreAntiforgeryToken]
public class ErrorPageModel : PageModel
{
    public string? RequestId { get; set; }

    public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);

    private readonly ILogger<ErrorPageModel> logger;

    public ErrorPageModel(ILogger<ErrorPageModel> logger)
    {
        this.logger = logger;
    }

    public void OnGet() => logger.LogInformation("Error page was loaded at {CurrentDateTime} with {RequestId}",
        DateTime.Now, RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier);
}