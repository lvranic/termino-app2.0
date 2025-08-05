using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using HotChocolate;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;
using TerminoApp.Data;
using TerminoApp.Models;

namespace TerminoApp.GraphQL
{
    [ExtendObjectType("Query")]
    public class UserQueries
    {
        public async Task<List<User>> GetUsersByRole(
            string role,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();
            return await context.Users
                .Where(u => u.Role == role)
                .ToListAsync();
        }

        public async Task<List<Service>> GetServicesByAdmin(
            string adminId,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            if (!int.TryParse(adminId, out var adminIdInt))
            {
                return new List<Service>();
            }

            return await context.Services
                .Where(s => s.AdminId == adminIdInt)
                .ToListAsync();
        }
    }
}