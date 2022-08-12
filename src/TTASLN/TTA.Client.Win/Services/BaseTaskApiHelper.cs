using System;
using System.Configuration;
using System.Net.Http;
using System.Threading.Tasks;
using Serilog;

namespace TTA.Client.Win.Services;

public abstract class BaseTaskApiHelper
{
    private readonly ILogger logger;

    protected BaseTaskApiHelper(ILogger logger)
    {
        this.logger = logger;
        var baseUrl = ConfigurationManager.AppSettings["ClientWebApiUrl"];
        Client = new HttpClient
        {
            BaseAddress = new Uri(baseUrl, UriKind.RelativeOrAbsolute)
        };
    }

    public async Task<bool> CheckHealthAsync()
    {
        logger.Information("Calling health endpoint at {DateCalled}", DateTime.Now);
        try
        {
            var httpResponseMessage = await Client.GetAsync("health");
            return httpResponseMessage.IsSuccessStatusCode;
        }
        catch (Exception e)
        {
            logger.Error(e.Message);
            return false;
        }
    }

    protected HttpClient Client { get; }
}