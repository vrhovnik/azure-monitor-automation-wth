using System.Windows;
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
}