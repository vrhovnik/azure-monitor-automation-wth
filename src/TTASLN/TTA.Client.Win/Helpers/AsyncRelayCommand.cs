using System;
using System.Threading.Tasks;
using System.Windows.Input;

namespace TTA.Client.Win.Helpers;

public class CommandAsync<T> : ICommand
{
    private readonly Func<T, Task> executeTask;
    private readonly Predicate<object> canExecute;
    private bool _locked;

    public CommandAsync(Func<T, Task> executeTask) : this(executeTask, _ => true)
    {
    }

    public CommandAsync(Func<T, Task> executeTask, Predicate<object> canExecute)
    {
        this.executeTask = executeTask;
        this.canExecute = canExecute;
    }

    public bool CanExecute(object parameter) => !_locked && canExecute.Invoke(parameter);

    public async void Execute(object parameter)
    {
        try
        {
            _locked = true;
            CanExecuteChanged?.Invoke(this, EventArgs.Empty);
            await executeTask.Invoke((T)parameter);
        }
        finally
        {
            _locked = false;
            CanExecuteChanged?.Invoke(this, EventArgs.Empty);
        }
    }

    public event EventHandler CanExecuteChanged;
    public void ChangeCanExecute() => CanExecuteChanged?.Invoke(this, EventArgs.Empty);
}