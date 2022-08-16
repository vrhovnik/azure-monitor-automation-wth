using Serilog;
using TTA.Client.Win.Helpers;
using TTA.Client.Win.ViewModels;

namespace TTA.Client.Win.Pages;

public partial class AddCommentWindow : IClosable
{
    private readonly ILogger logger;

    public AddCommentWindow(ILogger logger, string workTaskId)
    {
        this.logger = logger;
        InitializeComponent();
        Loaded += (_, _) =>
        {
            var addCommentPageViewModel = new AddCommentPageViewModel(logger, workTaskId);
            DataContext = addCommentPageViewModel;
        };
    }
}