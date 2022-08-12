using System;
using System.Threading.Tasks;
using Serilog;
using TTA.Core;
using TTA.Models;

namespace TTA.Client.Win.Services;

public class WorkTaskApiHelper : BaseTaskApiHelper
{
    public WorkTaskApiHelper(ILogger logger) : base(logger)
    {
    }

    public Task<PaginatedList<WorkTask>> GetTaskForUsersAsync()
    {
        throw new NotImplementedException();
    }
}