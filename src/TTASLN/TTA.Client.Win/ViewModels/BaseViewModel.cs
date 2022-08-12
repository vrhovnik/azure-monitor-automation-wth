using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using Serilog;
using TTA.Client.Win.Helpers;

namespace TTA.Client.Win.ViewModels;

public abstract class BaseViewModel : INotifyPropertyChanged
{
    protected readonly ILogger logger;
    private bool isWorking;
    private string message;

    protected BaseViewModel(ILogger logger)
    {
        this.logger = logger;
    }

    public string Version => AppHelpers.Version;

    public bool IsWorking
    {
        get => isWorking;
        set
        {
            if (value == isWorking) return;
            isWorking = value;
            OnPropertyChanged();
        }
    }

    public string Message
    {
        get => message;
        set
        {
            if (value == message) return;
            message = value;
            OnPropertyChanged();
        }
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null) => 
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));

    protected bool SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value)) return false;
        field = value;
        OnPropertyChanged(propertyName);
        return true;
    }
}