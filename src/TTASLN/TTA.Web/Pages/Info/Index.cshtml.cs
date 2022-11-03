using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TTA.Interfaces;

namespace TTA.Web.Pages;

[AllowAnonymous]
public class IndexPageModel : PageModel
{
    private readonly ILogger<IndexPageModel> logger;
    private readonly IQuoteService quoteService;

    public IndexPageModel(ILogger<IndexPageModel> logger, IQuoteService quoteService)
    {
        this.logger = logger;
        this.quoteService = quoteService;
    }

    public async Task OnGetAsync()
    {
        logger.LogInformation("Main info page has been loaded at {CurrentDateTime}", DateTime.Now);
        ServerName = Environment.MachineName;
        QuoteOfTheDay = await quoteService.GetQOTDAsync();
        logger.LogInformation("Received {QOTD}", QuoteOfTheDay);
    }

    [BindProperty]
    public string ServerName { get; set; }
    
    [BindProperty]
    public string QuoteOfTheDay { get; set; }
}