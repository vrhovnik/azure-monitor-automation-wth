using TTA.StatGenerator;

IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices(services => { services.AddHostedService<StatCalculatorWorker>(); })
    .Build();

await host.RunAsync();