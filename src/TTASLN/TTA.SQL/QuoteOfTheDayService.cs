using System.Net.Http.Headers;
using Newtonsoft.Json.Linq;
using TTA.Interfaces;

namespace TTA.SQL;

public class QuoteOfTheDayService : IQuoteService
{
    private readonly HttpClient httpClient;

    public QuoteOfTheDayService() => httpClient = new HttpClient();

    public async Task<string> GetQOTDAsync()
    {
        const string url = "https://quotes.rest/qod?language=en";
        httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        var responseString = await httpClient.GetStringAsync(url);
        var qod = JObject.Parse(responseString);

        if (qod["contents"] == null) return string.Empty;
        
        var contents = (JObject)qod["contents"];
        var currentQuotes = (JArray)contents["quotes"];
        if (currentQuotes == null) return string.Empty;

        dynamic currentQuote = currentQuotes[0];
        return $"Author {currentQuote.author} in category {currentQuote.category} said: {currentQuote.quote}";
    }
}