using System.Windows;
using TTA.Client.Win.ViewModels;

namespace TTA.Client.Win.Pages;

public partial class MainWindow
{
    public MainWindow()
    {
        InitializeComponent();

        async void OnLoaded(object o, RoutedEventArgs routedEventArgs)
        {
            var mainViewModel = new MainPageViewModel();
            mainViewModel.RegisterKeyHandler(this);
            await mainViewModel.LoadInitialDataAsync();
            DataContext = mainViewModel;
        }

        Loaded += OnLoaded;
    }
}