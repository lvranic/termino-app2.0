using HotChocolate;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;
using TerminoApp.Data;
using TerminoApp.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TerminoApp.GraphQL
{
    [ExtendObjectType("Query")]
    public class UnavailableDayQueries
    {
        public async Task<List<UnavailableDay>> GetUnavailableDays(
            string adminId,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            if (!int.TryParse(adminId, out int parsedId))
            {
                throw new GraphQLException("Neispravan admin ID.");
            }

            return await context.UnavailableDays
                .Where(u => u.AdminId == parsedId)
                .ToListAsync();
        }
    }
}