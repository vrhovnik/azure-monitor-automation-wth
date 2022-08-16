using System.Security.Principal;
using System.Windows;
using Microsoft.Extensions.DependencyInjection;
using Serilog;
using TTA.Client.Win.Pages;

namespace TTA.Client.Win;

public partial class App
{
    private readonly ServiceProvider serviceProvider;

    public App()
    {
        var services = new ServiceCollection();
        ConfigureServices(services);
        serviceProvider = services.BuildServiceProvider();
    }

    private void ConfigureServices(ServiceCollection services)
    {
        ILogger log = new LoggerConfiguration()
            .Enrich.FromLogContext()
            .WriteTo.File("log.txt", rollingInterval: RollingInterval.Day)
            .CreateLogger();
            
        if (new WindowsPrincipal(WindowsIdentity.GetCurrent()).IsInRole(WindowsBuiltInRole.Administrator))
        {
            log = new LoggerConfiguration()
                .Enrich.FromLogContext()
                .WriteTo.EventLog("TTA",manageEventSource:true)
                .CreateLogger();
        }

        services.AddSingleton(log);
        services.AddSingleton<MainWindow>(); 
        services.AddSingleton<AddCommentWindow>();
    }

    private void OnStartup(object sender, StartupEventArgs e)
    {
        var mainWindow = serviceProvider.GetService<MainWindow>();
        mainWindow.Show();
    }
}