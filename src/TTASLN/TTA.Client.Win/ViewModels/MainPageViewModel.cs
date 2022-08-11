using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using Microsoft.Xaml.Behaviors.Core;
using TTA.Client.Win.Helpers;

namespace TTA.Client.Win.ViewModels;

public class MainPageViewModel : BaseViewModel
{
    public MainPageViewModel()
    {
        OpenGithubPageCommand = new ActionCommand(OpenGithubAction);
        UserCount = 1;
    }

    public void RegisterKeyHandler(Window window)
    {
        var hotKeyHandler = new HotKeyHandler();
        hotKeyHandler.RegisterHotKey(window,
            (int)InteropAndHelpers.Modifiers.Win,
            (int)Keys.F12);
        hotKeyHandler.OnHotKeyPressed += (_, _) => window.Show();
    }

    public int UserCount
    {
        get => userCount;
        set
        {
            if (value == userCount) return;
            userCount = value;
            OnPropertyChanged();
        }
    }

    public async Task LoadInitialDataAsync()
    {
        IsWorking = true;
        Message = "Loading data from web api for users and for active tasks";
        await Task.Delay(5000);
        UserCount = 100;
        IsWorking = false;
    }

    private string query;
    private int userCount;

    public string Query
    {
        get => query;
        set
        {
            if (value == query) return;
            query = value;
            OnPropertyChanged();
        }
    }
    
    private void OpenGithubAction()
    {
        var processStartInfo = new ProcessStartInfo("https://github.com/vrhovnik/wndforme")
        {
            UseShellExecute = true
        };
        Process.Start(processStartInfo);
    }

    public ICommand OpenGithubPageCommand { get; }
}