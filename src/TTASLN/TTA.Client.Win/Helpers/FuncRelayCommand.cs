using System;
using System.Windows.Input;

namespace TTA.Client.Win.Helpers;

public class FuncRelayCommand<TParameter> : ICommand
{
    private readonly Predicate<TParameter> canExecute;
    private readonly Action<TParameter> execute;

    public FuncRelayCommand(Action<TParameter> execute,Predicate<TParameter> canExecute)
    {
        this.canExecute = canExecute;
        this.execute = execute;
    }

    public bool CanExecute(object parameter) => canExecute == null || canExecute((TParameter)parameter);

    public void Execute(object parameter) => execute((TParameter)parameter);

    public event EventHandler CanExecuteChanged    
    {    
        add => CommandManager.RequerySuggested += value;
        remove => CommandManager.RequerySuggested -= value;
    }  
}