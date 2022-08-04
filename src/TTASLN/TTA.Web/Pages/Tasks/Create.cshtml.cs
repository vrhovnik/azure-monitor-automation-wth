using Microsoft.AspNetCore.Mvc;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.Base;

namespace TTA.Web.Pages.Tasks;

public class CreatePageModel : BasePageModel
{
    private readonly ILogger<CreatePageModel> logger;
    private readonly IWorkTaskRepository workTaskRepository;
    private readonly IUserDataContext userDataContext;
    private readonly ICategoryRepository categoryRepository;
    private readonly ITagRepository tagRepository;

    public CreatePageModel(ILogger<CreatePageModel> logger,
        IWorkTaskRepository workTaskRepository,
        IUserDataContext userDataContext,
        ICategoryRepository categoryRepository,
        ITagRepository tagRepository)
    {
        this.logger = logger;
        this.workTaskRepository = workTaskRepository;
        this.userDataContext = userDataContext;
        this.categoryRepository = categoryRepository;
        this.tagRepository = tagRepository;
    }

    public async Task OnGetAsync()
    {
        logger.LogInformation("Loaded Create task page at {DateLoaded}", DateTime.Now);
        Categories = await categoryRepository.GetAllAsync();
        logger.LogInformation("Loaded {CategoriesCount}", Categories.Count);
        Tags = await tagRepository.GetAllAsync();
        logger.LogInformation("Loaded {TagsCount}", Tags.Count);
    }

    public async Task<IActionResult> OnPostAsync()
    {
        var form = await Request.ReadFormAsync();
        var tagsForm = form["ddlTags"];
        foreach (var currentTag in tagsForm)
        {
            NewTask.Tags.Add(new Tag { TagName = currentTag });
        }

        var categoryForm = form["ddlCategories"];
        var category = await categoryRepository.DetailsAsync(categoryForm[0]);
        NewTask.Category = category;

        var currentUser = userDataContext.GetCurrentUser();
        NewTask.User = new TTAUser { TTAUserId = currentUser.UserId, Email = currentUser.Email };

        try
        {
            await workTaskRepository.InsertAsync(NewTask);
        }
        catch (Exception e)
        {
            logger.LogError(e.Message);
            Message = "Error with inserting new task, check logs.";
            return Page();
        }

        return RedirectToPage("/Task/Index");
    }

    [BindProperty] public List<Category> Categories { get; set; }
    [BindProperty] public List<Tag> Tags { get; set; }
    [BindProperty] public WorkTask NewTask { get; set; }
}