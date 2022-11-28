using System.IO.Compression;
using Microsoft.ApplicationInsights.DependencyCollector;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.ResponseCompression;
using TTA.Interfaces;
using TTA.SQL;
using TTA.Web.Base;
using TTA.Web.Options;

var builder = WebApplication.CreateBuilder(args);
//options
builder.Services.Configure<GeneralWebOptions>(builder.Configuration.GetSection("AppOptions"));
builder.Services.Configure<SqlOptions>(builder.Configuration.GetSection("SqlOptions"));

//adding interface mappings for services connecting to SQL
var sqlOptions = builder.Configuration.GetSection("SqlOptions").Get<SqlOptions>();
builder.Services.AddTransient<IUserRepository, TTAUserRepository>(_ =>
    new TTAUserRepository(sqlOptions.ConnectionString));
builder.Services.AddTransient<ICategoryRepository, CategoryRepository>(_ =>
    new CategoryRepository(sqlOptions.ConnectionString));
builder.Services.AddTransient<ITagRepository, TagRepository>(_ =>
    new TagRepository(sqlOptions.ConnectionString));
builder.Services.AddTransient<IWorkTaskRepository, WorkTaskRepository>(_ =>
    new WorkTaskRepository(sqlOptions.ConnectionString));
builder.Services.AddTransient<IProfileSettingsService, ProfileSettingsService>(_ =>
    new ProfileSettingsService(sqlOptions.ConnectionString));
builder.Services.AddTransient<IWorkTaskCommentRepository, WorkTaskCommentRepository>(_ =>
    new WorkTaskCommentRepository(sqlOptions.ConnectionString));

//adding other services
builder.Services.AddScoped<IQuoteService, QuoteOfTheDayService>();

//core system settings
builder.Services.AddScoped<IUserDataContext, UserDataContext>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddSingleton<ITempDataProvider, CookieTempDataProvider>();
builder.Services.AddResponseCompression(options => options.Providers.Add<GzipCompressionProvider>());
builder.Services.Configure<GzipCompressionProviderOptions>(compressionOptions =>
    compressionOptions.Level = CompressionLevel.Optimal);
builder.Services.AddHealthChecks();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options => options.LoginPath = new PathString("/User/Login"));
builder.Services.AddRazorPages().AddRazorPagesOptions(options =>
    options.Conventions.AddPageRoute("/Info/Index", ""));

// builder.Services.AddApplicationInsightsTelemetry();
// builder.Services.ConfigureTelemetryModule<DependencyTrackingTelemetryModule>((module, _) =>
// {
//     module.EnableSqlCommandTextInstrumentation = true;
// });

var app = builder.Build();

if (!app.Environment.IsDevelopment()) app.UseExceptionHandler("/Error");

app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.UseEndpoints(endpoints =>
{
    endpoints.MapHealthChecks("/health").AllowAnonymous();
    endpoints.MapRazorPages();
});
app.Run();