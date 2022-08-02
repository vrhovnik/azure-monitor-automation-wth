using TTA.Web.ViewModels;

namespace TTA.Web.Base;

public interface IUserDataContext
{
    UserViewModel GetCurrentUser();
}