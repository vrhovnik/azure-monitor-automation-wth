using System;
using System.Threading.Tasks;
using TTA.Core;
using TTA.Models;

namespace TTA.Client.Win.Services;

public class WorkTaskApiHelper : BaseTaskApiHelper
{
    

    public Task<PaginatedList<WorkTask>> GetTaskForUsersAsync()
    {
        throw new NotImplementedException();
    }
}