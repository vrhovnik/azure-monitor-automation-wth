using System;
using System.Threading.Tasks;
using System.Windows.Input;
using MahApps.Metro.Controls;
using MahApps.Metro.Controls.Dialogs;
using Serilog;
using TTA.Client.Win.Helpers;
using TTA.Client.Win.Services;
using TTA.Models;

namespace TTA.Client.Win.ViewModels;

public class AddCommentPageViewModel : BaseViewModel
{
    private readonly string workTaskId;
    private bool hasBeenSaved;
    private WorkTaskComment taskComment;

    public AddCommentPageViewModel(ILogger logger, string workTaskId) : base(logger)
    {
        this.workTaskId = workTaskId;
        HasBeenSaved = false;
        SaveAndCloseCommand =
            new FuncRelayCommand<IClosable>(closableWindow =>  closableWindow.Close(), _ => true);
        CloseCommand =
            new FuncRelayCommand<IClosable>(async closable => await CloseWindowHandler(closable), _ => true);
    }

    private async Task SaveDataAsync()
    {
        TaskComment.StartDate = DateTime.Now;
        TaskComment.AssignedTask = new WorkTask { WorkTaskId = workTaskId };
        TaskComment.User = new TTAUser { TTAUserId = AppHelpers.LoggedUserId };

        try
        {
            var workTaskApi = new WorkTaskApiHelper(logger);
            await workTaskApi.AddCommentAsync(TaskComment);
            HasBeenSaved = true;
        }
        catch (Exception e)
        {
            logger.Error(e.Message);
            HasBeenSaved = false;
        }
    }
    
    private async Task CloseWindowHandler(IClosable window)
    {
        await SaveDataAsync();

        if (HasBeenSaved) window.Close();
        else
        {
            var showDialog = await ((MetroWindow)window).ShowMessageAsync("Data was not saved",
                "Data was not saved, do you want to continue?", MessageDialogStyle.AffirmativeAndNegative);
            if (showDialog == MessageDialogResult.Affirmative) window.Close();
        }
    }

    public WorkTaskComment TaskComment
    {
        get => taskComment;
        set
        {
            if (Equals(value, taskComment)) return;
            taskComment = value;
            OnPropertyChanged();
        }
    }

    public bool HasBeenSaved
    {
        get => hasBeenSaved;
        set
        {
            if (value == hasBeenSaved) return;
            hasBeenSaved = value;
            OnPropertyChanged();
        }
    }

    public ICommand SaveAndCloseCommand { get; }
    public ICommand CloseCommand { get; }
}