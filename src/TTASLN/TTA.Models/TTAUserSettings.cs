namespace TTA.Models;

public class TTAUserSettings : ContentModel
{
    public bool EmailNotification { get; set; }
    public TTAUser User { get; set; }
}