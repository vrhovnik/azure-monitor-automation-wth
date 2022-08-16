using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using Bogus;
using Microsoft.Xaml.Behaviors.Core;
using Serilog;
using TTA.Client.Win.Helpers;
using TTA.Client.Win.Pages;
using TTA.Client.Win.Services;
using TTA.Models;

namespace TTA.Client.Win.ViewModels;

public class MainPageViewModel : BaseViewModel
{
    public MainPageViewModel(ILogger logger) : base(logger)
    {
        OpenGithubPageCommand = new ActionCommand(OpenGithubAction);
        SimulateUserApiConnectivityToTasksCommand = new ActionCommand(_ => StartSimulationActionAsync());
        CheckWebApiClientHealthCommand = new ActionCommand(_ => CheckWebApiClientHealthActionAsync());
        OpenAddCommentWindowCommand = new ActionCommand(workItemId =>
        {
            var addCommentWindow = new AddCommentWindow(logger, workItemId.ToString());
            addCommentWindow.ShowDialog();
        });
        UserCount = 1;
        Query = string.Empty;
        IsWebApiHealthy = false;
        HealthTitleMessage = "Information about web api health unknown.";
    }

    public async Task GetUserWorkTasksAsync()
    {
        IsWorking = true;
        if (string.IsNullOrEmpty(AppHelpers.LoggedUserId))
        {
            MessageBox.Show("Set user identificator in app settings to be able to search for tasks");
            return;
        }

        Message = $"Loading tasks with query {Query}.";
        var workTaskHelper = new WorkTaskApiHelper(logger);
        TaskForUsers = await workTaskHelper.GetTaskForUsersAsync(AppHelpers.LoggedUserId, Query);
        Message = $"Loaded {TaskForUsers.Count} items.";
        IsWorking = false;
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

    private async Task StartSimulationActionAsync()
    {
        var random = new Random();
        var workTaskApiHelper = new WorkTaskApiHelper(logger);
        IsWorking = true;
        foreach (var user in users)
        {
            Message = $"Adding comments to work tasks by user {user.FullName}";
            var workTasks = await workTaskApiHelper.GetTaskForUsersAsync(user.TTAUserId, string.Empty);
            foreach (var workTask in workTasks)
            {
                var randomComments = random.Next(1, 10);
                for (var currentCounter = 1; currentCounter <= randomComments; currentCounter++)
                {
                    Message =
                        $"Adding messages {currentCounter} out of {randomComments} to work task {workTask.WorkTaskId} by user {user.FullName}";
                    await workTaskApiHelper.AddCommentAsync(new WorkTaskComment
                    {
                        User = user,
                        StartDate = DateTime.Now,
                        AssignedTask = workTask,
                        Comment = new Faker().Lorem.Sentence(new Random().Next(5, 20))
                    });
                    Message =
                        $"Added message {currentCounter} out of {randomComments} to work task {workTask.WorkTaskId}";
                }
            }
        }

        IsWorking = false;
    }

    private async Task CheckWebApiClientHealthActionAsync()
    {
        var workTaskApiCaller = new WorkTaskApiHelper(logger);
        IsWorking = true;
        IsWebApiHealthy = await workTaskApiCaller.CheckHealthAsync();
        HealthTitleMessage = IsWebApiHealthy ? "Web Api is connected" : "Web api cannot be reached";
        Message = healthTitleMessage;
        IsWorking = false;
    }

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

    private int userCount;
    private bool isWebApiHealthy;
    private string healthTitleMessage;
    private List<TTAUser> users;
    private string query;
    private List<WorkTask> taskForUsers;

    public List<WorkTask> TaskForUsers
    {
        get => taskForUsers;
        set
        {
            if (Equals(value, taskForUsers)) return;
            taskForUsers = value;
            OnPropertyChanged();
        }
    }

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
    public ICommand OpenAddCommentWindowCommand { get; }
}