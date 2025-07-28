using TerminoApp.Data;
using TerminoApp.Models;
using HotChocolate;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.EntityFrameworkCore;
#nullable enable

public class Query
{
    public async Task<List<User>> GetUsers([Service] IDbContextFactory<AppDbContext> contextFactory)
    {
        using var context = contextFactory.CreateDbContext();
        return await context.Users.ToListAsync();
    }

    public async Task<List<Service>> GetServices([Service] IDbContextFactory<AppDbContext> contextFactory)
    {
        using var context = contextFactory.CreateDbContext();
        return await context.Services.ToListAsync();
    }

    public async Task<List<Reservation>> GetReservations([Service] IDbContextFactory<AppDbContext> contextFactory)
    {
        using var context = contextFactory.CreateDbContext();
        return await context.Reservations.ToListAsync();
    }

    public async Task<List<UnavailableDay>> GetUnavailableDays([Service] IDbContextFactory<AppDbContext> contextFactory)
    {
        using var context = contextFactory.CreateDbContext();
        return await context.UnavailableDays.ToListAsync();
    }

    public async Task<User?> Login(string email, string password, [Service] IDbContextFactory<AppDbContext> contextFactory)
    {
        using var context = contextFactory.CreateDbContext();
        return await context.Users.FirstOrDefaultAsync(u => u.Email == email && u.Password == password);
    }
}