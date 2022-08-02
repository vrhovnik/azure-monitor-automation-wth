namespace TTA.Models;

public class WorkTask
{
    public string WorkTaskId { get; set; }
    public string Description { get; set; }
    public DateTime Start { get; set; }
    public DateTime End { get; set; }
    public int DurationInMs => End.Millisecond - Start.Millisecond;
    public List<Tag> Tags { get; set; } = new();
    public Category Category { get; set; } = new();
}