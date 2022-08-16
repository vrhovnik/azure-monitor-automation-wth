using System.Configuration;
using System.Reflection;

namespace TTA.Client.Win.Helpers;

public static class AppHelpers
{
    public static string? Version => Assembly.GetEntryAssembly()?.GetName().Version?.ToString();
    public static readonly string LoggedUserId = ConfigurationManager.AppSettings["LoggedUserId"];
    public static readonly string ClientWebApiUrl = ConfigurationManager.AppSettings["ClientWebApiUrl"];
}