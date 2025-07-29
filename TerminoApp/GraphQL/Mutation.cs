using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HotChocolate;
using HotChocolate.Types;
using TerminoApp.Data;
using TerminoApp.Models;
using TerminoApp.GraphQL.Inputs;

#nullable enable

namespace TerminoApp.GraphQL
{
    public class Mutation
    {
        public async Task<User> AddUser(
            [GraphQLName("input")] UserInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            var user = new User
            {
                Name = input.Name,
                Email = input.Email,
                Phone = input.Phone,
                Role = input.Role,
                Password = input.Password
            };

            context.Users.Add(user);
            await context.SaveChangesAsync();
            return user;
        }

        public async Task<Service> AddService(
            [GraphQLName("input")] ServiceInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            var service = new Service
            {
                Name = input.Name,
                Description = input.Description,
                Address = input.Address,
                WorkingHours = input.WorkingHours,
                AdminId = input.AdminId
            };

            context.Services.Add(service);
            await context.SaveChangesAsync();
            return service;
        }

        public async Task<Reservation> AddReservation(
            [GraphQLName("input")] ReservationInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

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

        public async Task<UnavailableDay> AddUnavailableDay(
            [GraphQLName("input")] UnavailableDayInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            var unavailableDay = new UnavailableDay
            {
                Date = input.Date
            };

            context.UnavailableDays.Add(unavailableDay);
            await context.SaveChangesAsync();
            return unavailableDay;
        }
    }
}