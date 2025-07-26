using TerminoApp.Data;
using TerminoApp.Models;
using HotChocolate;
using HotChocolate.Data;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

public class Query
{
    [UseDbContext(typeof(AppDbContext))]
    public async Task<List<User>> GetUsers([Service] AppDbContext context) =>
        await Task.FromResult(context.Users.ToList());

    [UseDbContext(typeof(AppDbContext))]
    public async Task<List<Service>> GetServices([Service] AppDbContext context) =>
        await Task.FromResult(context.Services.ToList());

    [UseDbContext(typeof(AppDbContext))]
    public async Task<List<Reservation>> GetReservations([Service] AppDbContext context) =>
        await Task.FromResult(context.Reservations.ToList());

    [UseDbContext(typeof(AppDbContext))]
    public async Task<List<UnavailableDay>> GetUnavailableDays([Service] AppDbContext context) =>
        await Task.FromResult(context.UnavailableDays.ToList());

    // ✅ Dodano ispravno unutar klase
    [UseDbContext(typeof(AppDbContext))]
    public async Task<User?> Login(string email, string password, [Service] AppDbContext context)
    {
        return await Task.FromResult(
            context.Users.FirstOrDefault(u => u.Email == email && u.Password == password)
        );
    }
}