namespace TTA.Models;

public class TTAUser
{
    public string TTAUserId { get; set; }
    public string FullName { get; set; }
    public string Email { get; set; }
    public string Password { get; set; }
    public string Salt { get; set; }
    public List<WorkTask> Tasks { get; set; } = new();
    public TTAUserSettings UserSettings { get; set; } = new();
}