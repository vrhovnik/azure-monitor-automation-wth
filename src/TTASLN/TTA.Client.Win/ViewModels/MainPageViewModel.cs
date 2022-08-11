using System;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using Microsoft.Xaml.Behaviors.Core;
using TTA.Client.Win.Helpers;
using TTA.Client.Win.Services;

namespace TTA.Client.Win.ViewModels;

public class MainPageViewModel : BaseViewModel
{
    public MainPageViewModel()
    {
        OpenGithubPageCommand = new ActionCommand(OpenGithubAction);
        SimulateUserApiConnectivityToTasksCommand = new ActionCommand(StartSimulationAction);
        CheckWebApiClientHealthCommand = new ActionCommand(CheckWebApiClientHealthAction);
        UserCount = 1;
    }

    private void StartSimulationAction()
    {
        throw new NotImplementedException();
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

    public string SimulationData
    {
        get => simulationData;
        set
        {
            if (value == simulationData) return;
            simulationData = value;
            OnPropertyChanged();
        }
    }

    public async Task LoadInitialDataAsync()
    {
        IsWorking = true;
        Message = "Loading data from web api for users and for active tasks";
        
        var userApiHelper = new UserTaskApiHelper();
        var users = await userApiHelper.GetUsersAsync();
        Message = $"Received {users.Count} users from web api";
        UserCount = users.Count;
        // UserCount = 100;
        // await Task.Delay(2000);
        IsWorking = false;
    }

    private int userCount;
    private string simulationData;

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
    public ICommand SimulateUserApiConnectivityToTasksCommand { get; }
}