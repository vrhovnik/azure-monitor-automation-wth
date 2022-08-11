using TTA.Interfaces;
using TTA.SQL;
using TTA.Web.ClientApi.Options;

const string allowOrigins = "_projectStardustAllowedOrigins";
var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<GeneralWebOptions>(builder.Configuration.GetSection("AppOptions"));
builder.Services.Configure<SqlOptions>(builder.Configuration.GetSection("SqlOptions"));

var sqlOptions = builder.Configuration.GetSection("SqlOptions").Get<SqlOptions>();
builder.Services.AddTransient<IUserRepository, TTAUserRepository>(_ =>
    new TTAUserRepository(sqlOptions.ConnectionString));
builder.Services.AddTransient<IWorkTaskRepository, WorkTaskRepository>(_ =>
    new WorkTaskRepository(sqlOptions.ConnectionString));

builder.Services.AddControllers();
builder.Services.AddHealthChecks();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: allowOrigins,
        policy =>
        {
            // policy.WithOrigins("https://projectstardustwebapi.azurewebsites.net",
            //     "https://localhost:")
            //     .AllowAnyMethod();
            policy.AllowAnyOrigin()
                .AllowAnyMethod()
                .WithExposedHeaders("x-project-stardust")
                .AllowCredentials();
        });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.UseAuthorization();
app.UseCors(allowOrigins);
app.UseEndpoints(endpoints =>
{
    endpoints.MapHealthChecks("/health").AllowAnonymous();
    endpoints.MapControllers();
});
app.Run();