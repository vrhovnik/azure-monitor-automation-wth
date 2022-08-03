using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.Cookies;
using TTA.Models;

namespace TTA.Web.Base;

public static class UserDataContextExtensions
{
    public static ClaimsPrincipal GenerateClaims(this TTAUser user)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.Name, user.FullName),
            new(ClaimTypes.NameIdentifier, user.TTAUserId),
            new(ClaimTypes.Email, user.Email)
        };
        return new ClaimsPrincipal(new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme));
    }
}