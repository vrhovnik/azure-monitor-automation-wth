using Serilog;
using TTA.Interfaces;
using TTA.SQL;
using TTA.StatGenerator;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureLogging((_, builder) => builder.AddConsole())
    .ConfigureServices((hostContext, services) =>
    {
        services.Configure<HostOptions>(options =>
        {
            options.BackgroundServiceExceptionBehavior = BackgroundServiceExceptionBehavior.Ignore;
            options.ShutdownTimeout = TimeSpan.FromSeconds(30);
        });
        
        services.Configure<SqlOptions>(hostContext.Configuration.GetSection("SqlOptions"));

        services.AddHostedService<StatCalculatorWorker>();
        
        var sqlConfig = hostContext.Configuration.GetSection("SqlOptions").Get<SqlOptions>();
        services.AddScoped<IWorkTaskRepository, WorkTaskRepository>(_ => 
            new WorkTaskRepository(sqlConfig.ConnectionString));
        services.AddScoped<IWorkStatsRepository, WorkTaskStatsRepository>(_ =>
            new WorkTaskStatsRepository(sqlConfig.ConnectionString));
        
        Log.Logger = new LoggerConfiguration()
            .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Type} {Message:lj} {NewLine}{Exception}")
            .CreateLogger();
    })
    .Build();

await host.RunAsync();