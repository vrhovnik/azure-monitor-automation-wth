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
        CheckWebApiClientHealthCommand = new ActionCommand(CheckWebApiClientHealthAction);
        UserCount = 1;
    }

    private void CheckWebApiClientHealthAction()
    {
        //check http call and notify user if API call was successful
    }

    public void RegisterKeyHandler(Window window)
    {
        var hotKeyHandler = new HotKeyHandler();
        hotKeyHandler.OnHotKeyPressed += (_, _) =>
        {
            if (window.WindowState == WindowState.Minimized)
                window.WindowState = WindowState.Normal;
        };
        hotKeyHandler.RegisterHotKey(window,
            (int)InteropAndHelpers.Modifiers.Win,
            (int)Keys.PageUp);
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
        await Task.Delay(2000);
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
    public ICommand CheckWebApiClientHealthCommand { get; }
}