using TerminoApp.Data;
using TerminoApp.Models;
using HotChocolate;
using HotChocolate.Types;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

#nullable enable
namespace TerminoApp.GraphQL
{
    public class Query
    {
        [GraphQLName("getUsers")]
        public async Task<List<User>> GetUsers([Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();
            return await context.Users.ToListAsync();
        }

        [GraphQLName("getServices")]
        public async Task<List<Service>> GetServices([Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();
            return await context.Services.ToListAsync();
        }

        [GraphQLName("getReservations")]
        public async Task<List<Reservation>> GetReservations([Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();
            return await context.Reservations.ToListAsync();
        }

        [GraphQLName("getUnavailableDays")]
        public async Task<List<UnavailableDay>> GetUnavailableDays([Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();
            return await context.UnavailableDays.ToListAsync();
        }

        [GraphQLName("loginUser")]
        public async Task<User?> Login(string email, string password, [Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();
            return await context.Users.FirstOrDefaultAsync(u => u.Email == email && u.Password == password);
        }

        [GraphQLName("service")]
        public async Task<Service?> GetServiceById(string id, [Service] IDbContextFactory<AppDbContext> contextFactory)
        {
            using var context = contextFactory.CreateDbContext();

            if (!int.TryParse(id, out var intId))
            {
                return null;
            }

            return await context.Services
                .Include(s => s.Admin)
                .FirstOrDefaultAsync(s => s.Id == intId);
        }
    }
}