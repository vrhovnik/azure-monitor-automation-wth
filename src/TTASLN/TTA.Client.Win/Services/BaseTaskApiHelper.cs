using System;
using System.Configuration;
using System.Net.Http;

namespace TTA.Client.Win.Services;

public abstract class BaseTaskApiHelper
{
    protected BaseTaskApiHelper()
    {
        var baseUrl = ConfigurationManager.AppSettings["ClientWebApiUrl"];
        Client = new HttpClient
        {
            BaseAddress = new Uri(baseUrl, UriKind.RelativeOrAbsolute)
        };
    }

    protected HttpClient Client { get; }
}