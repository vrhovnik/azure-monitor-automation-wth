using System.Reflection;

namespace TTA.Client.Win.Helpers;

public class AppHelpers
{
    public static string? Version => Assembly.GetEntryAssembly()?.GetName().Version?.ToString();
}