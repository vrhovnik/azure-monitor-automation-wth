using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Serilog;
using TTA.Client.Win.ViewModels;

namespace TTA.Client.Win.Pages;

public partial class MainWindow
{
    private readonly ILogger logger;

    public MainWindow(ILogger logger)
    {
        this.logger = logger;
        InitializeComponent();

        async void OnLoaded(object o, RoutedEventArgs routedEventArgs)
        {
            logger.Information("Client Application has been invoked at {DateCreated}");
            var mainViewModel = new MainPageViewModel(logger);
            mainViewModel.RegisterKeyHandler(this);
            await mainViewModel.LoadInitialDataAsync();
            DataContext = mainViewModel;
        }

        Loaded += OnLoaded;
    }

    private async void KeyUpHandled(object sender, KeyEventArgs e)
    {
        if (e.Key != Key.Enter) return;

        var mainPageViewModel = (MainPageViewModel)DataContext;
        mainPageViewModel.Query = (sender as TextBox)?.Text;
        await mainPageViewModel.GetUserWorkTasksAsync();
    }
}