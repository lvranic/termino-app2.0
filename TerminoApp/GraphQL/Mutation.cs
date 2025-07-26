using System;
using System.Threading.Tasks;
using TerminoApp.Data;
using TerminoApp.GraphQL.Inputs;
using TerminoApp.Models;
using HotChocolate;
using HotChocolate.Data;

public class Mutation
{
    [UseDbContext(typeof(AppDbContext))]
    public async Task<User> AddUser(UserInput input, [ScopedService] AppDbContext context)
    {
        try
        {
            var user = new User
            {
                Name = input.Name,
                Email = input.Email,
                Phone = input.Phone,
                Role = input.Role
            };

            context.Users.Add(user);
            await context.SaveChangesAsync();
            return user;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Greška u AddUser: {ex}");
            throw new GraphQLException($"Greška prilikom spremanja korisnika: {ex.Message}");
        }
    }

    [UseDbContext(typeof(AppDbContext))]
    public async Task<Service> AddService(ServiceInput input, [ScopedService] AppDbContext context)
    {
        var service = new Service
        {
            Name = input.Name,
            Description = input.Description,
            DurationMinutes = input.DurationMinutes,
            Price = input.Price
        };

        context.Services.Add(service);
        await context.SaveChangesAsync();
        return service;
    }

    [UseDbContext(typeof(AppDbContext))]
    public async Task<Reservation> AddReservation(ReservationInput input, [ScopedService] AppDbContext context)
    {
        var reservation = new Reservation
        {
            UserId = input.UserId,
            ServiceId = input.ServiceId,
            DateTime = input.DateTime
        };

        context.Reservations.Add(reservation);
        await context.SaveChangesAsync();
        return reservation;
    }

    [UseDbContext(typeof(AppDbContext))]
    public async Task<UnavailableDay> AddUnavailableDay(UnavailableDayInput input, [ScopedService] AppDbContext context)
    {
        var unavailableDay = new UnavailableDay
        {
            Date = input.Date
        };

        context.UnavailableDays.Add(unavailableDay);
        await context.SaveChangesAsync();
        return unavailableDay;
    }
}