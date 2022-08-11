using System.Net.Mime;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using TTA.Interfaces;
using TTA.Models;
using TTA.Web.ClientApi.Options;

namespace TTA.Web.ClientApi.Controllers;

[Route("user-api")]
[Produces(MediaTypeNames.Application.Json)]
[ApiController]
public class UserApiController : ControllerBase
{
    private readonly ILogger<UserApiController> logger;
    private readonly IUserRepository userRepository;
    private readonly GeneralWebOptions webOptions;

    public UserApiController(ILogger<UserApiController> logger,
        IUserRepository userRepository,
        IOptions<GeneralWebOptions> webOptionsValue)
    {
        this.logger = logger;
        webOptions = webOptionsValue.Value;
        this.userRepository = userRepository;
    }
    
    [HttpGet]
    [Route("all")]
    [Produces(typeof(IEnumerable<TTAUser>))]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAllUsersAsync()
    {
        var ttaUsers = await userRepository.GetAsync();
        logger.LogInformation("Received {NumberOfUSers} users at {DateCalled}", ttaUsers.Count,
            DateTime.Now);

        return Ok(ttaUsers);
    }
}