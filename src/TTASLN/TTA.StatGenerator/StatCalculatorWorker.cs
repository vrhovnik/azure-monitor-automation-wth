using TTA.Interfaces;
using TTA.Models;

namespace TTA.StatGenerator;

public class StatCalculatorWorker : BackgroundService
{
    private readonly ILogger<StatCalculatorWorker> logger;
    private readonly IServiceProvider serviceProvider;
    
    public StatCalculatorWorker(ILogger<StatCalculatorWorker> logger,
        IServiceProvider serviceProvider)
    {
        this.logger = logger;
        this.serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);

        using var scope = serviceProvider.CreateScope();
        
        var workTaskRepository =
            scope.ServiceProvider.GetRequiredService<IWorkTaskRepository>();

        logger.LogInformation("Getting tasks for the {CurrentDate}", DateTime.Now);

        var tasksForToday = await workTaskRepository.GetTasksFromAsync(DateTime.Now.AddDays(-1),
            DateTime.Now);

        if (tasksForToday.Count == 0)
        {
            logger.LogInformation("No data received for {DateCalled}", DateTime.Now);
            return;
        }

        logger.LogInformation("Received {NumberOfTasks} tasks", tasksForToday.Count);

        var workTasksStatsRepository =
            scope.ServiceProvider.GetRequiredService<IWorkStatsRepository>();

        var workTask = tasksForToday.OrderBy(d => d.Comments.Count).First();

        var workTaskStats = new WorkTaskStats
        {
            DailyTasks = tasksForToday.TotalItems,
            PublicTasks = tasksForToday.Count(currentTask => currentTask.IsPublic),
            DateCreated = DateTime.Now,
            MostActiveTask = workTask,
            CommentNumber = tasksForToday.Sum(d => d.Comments.Count)
        };

        logger.LogInformation(
            "Today's {DateCreated} stats: {TotalItems} items, publically available {PublicallyAvailable} with {CommentNumber} comments and most active Work task {MostActiveWorkTask}",
            DateTime.Now, workTaskStats.DailyTasks, workTaskStats.PublicTasks, workTaskStats.CommentNumber,
            workTaskStats.MostActiveTask.WorkTaskId);

        await workTasksStatsRepository.InsertAsync(workTaskStats);
        logger.LogInformation("Stats completed {DateCompleted}", DateTime.Now);
    }
}