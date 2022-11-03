namespace TTA.Interfaces;

public interface IQuoteService
{
    Task<string> GetQOTDAsync();
}