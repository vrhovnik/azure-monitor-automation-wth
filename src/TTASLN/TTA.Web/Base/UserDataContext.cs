using System.Security.Claims;
using TTA.Web.ViewModels;

namespace TTA.Web.Base;

public class UserDataContext : IUserDataContext
{
    private readonly IHttpContextAccessor httpContextAccessor;

    public UserDataContext(IHttpContextAccessor httpContextAccessor) => 
        this.httpContextAccessor = httpContextAccessor;

    public UserViewModel GetCurrentUser()
    {
        var httpContextUser = httpContextAccessor.HttpContext.User;

        var currentUser = new UserViewModel();
        var claimName = httpContextUser.FindFirst(ClaimTypes.Name);
        currentUser.Fullname = claimName.Value;

        var claimId = httpContextUser.FindFirst(ClaimTypes.NameIdentifier);
        currentUser.UserId = claimId.Value;

        var claimAdmin = httpContextUser.FindFirst("IsAdmin");
        currentUser.IsAdmin = Convert.ToBoolean(claimAdmin.Value);

        var claimImageUrl = httpContextUser.FindFirst("ImageName");
        currentUser.ImageUrl = claimImageUrl.Value;

        return currentUser;
    }
}