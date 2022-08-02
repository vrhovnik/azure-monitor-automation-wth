using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace TTA.Web.Base;

public abstract class BasePageModel : PageModel
{
    [TempData]
    public string Message { get; set; }
}