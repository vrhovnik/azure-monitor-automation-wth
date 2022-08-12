using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using Microsoft.Xaml.Behaviors.Core;
using Serilog;
using TTA.Client.Win.Helpers;
using TTA.Client.Win.Services;
using TTA.Models;

namespace TTA.Client.Win.ViewModels;

public class MainPageViewModel : BaseViewModel
{
    public MainPageViewModel(ILogger logger) : base(logger)
    {
        OpenGithubPageCommand = new ActionCommand(OpenGithubAction);
        SimulateUserApiConnectivityToTasksCommand = new CommandAsync<object>(StartSimulationActionAsync);
        CheckWebApiClientHealthCommand = new CommandAsync<object>(CheckWebApiClientHealthActionAsync);
        UserCount = 1;
        IsWebApiHealthy = false;
        HealthTitleMessage = "Information about web api health unknown.";
    }

    public async Task LoadInitialDataAsync()
    {
        IsWorking = true;
        
        var currentMessage = $"Loading data from web api for users and for active tasks at {DateTime.Now}";
        Message = currentMessage;
        logger.Information(currentMessage);
        var userApiHelper = new UserTaskApiHelper(logger);
        users = await userApiHelper.GetUsersAsync();
        Message = $"Received {users.Count} users from web api";
        UserCount = users.Count;
        logger.Information("Loaded {UserCount} users from REST call at {DateCalled}", UserCount,
            DateTime.Now.ToShortDateString());
        await CheckWebApiClientHealthActionAsync();
        
        IsWorking = false;
    }

    private Task StartSimulationActionAsync(object lockObject)
    {
        throw new NotImplementedException();
    }

    private async Task CheckWebApiClientHealthActionAsync(object? lockObject = null)
    {
        var workTaskApiCaller = new WorkTaskApiHelper(logger);
        IsWorking = true;
        IsWebApiHealthy = await workTaskApiCaller.CheckHealthAsync();
        HealthTitleMessage = IsWebApiHealthy ? "Web Api is connected" : "Web api cannot be reached";
        IsWorking = false;
    }

    public bool IsWebApiHealthy
    {
        get => isWebApiHealthy;
        set
        {
            if (value == isWebApiHealthy) return;
            isWebApiHealthy = value;
            OnPropertyChanged();
        }
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

    public string HealthTitleMessage
    {
        get => healthTitleMessage;
        set
        {
            if (value == healthTitleMessage) return;
            healthTitleMessage = value;
            OnPropertyChanged();
        }
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

    private int userCount;
    private string simulationData;
    private bool isWebApiHealthy;
    private string healthTitleMessage;
    private List<TTAUser> users;

    private void OpenGithubAction()
    {
        logger.Information("Opening GH page at {DateCalled}", DateTime.Now);
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