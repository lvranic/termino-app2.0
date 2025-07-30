using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HotChocolate;
using HotChocolate.Types;
using TerminoApp.Data;
using TerminoApp.Models;
using TerminoApp.GraphQL.Inputs;
using TerminoApp.Services; // Ispravljen namespace!
using Microsoft.AspNetCore.Http;

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

            Console.WriteLine($"🟡 Pripremljen korisnik: {user.Name} ({user.Email})");

            await context.Users.AddAsync(user);
            Console.WriteLine("🟢 Dodan u context.Users");

            await context.SaveChangesAsync();
            Console.WriteLine("✅ Spremljen u bazu!");

            return user;
        }

        public async Task<Service> AddService(
            [GraphQLName("input")] ServiceInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory,
            [Service] IHttpContextAccessor contextAccessor)
        {
            var httpContext = contextAccessor.HttpContext;
            var userClaims = httpContext?.User;

            if (userClaims == null || !(userClaims.Identity?.IsAuthenticated ?? false) || userClaims.FindFirst("role")?.Value != "admin")
            {
                throw new GraphQLException("Nemate dopuštenje za ovu operaciju.");
            }

            await using var context = await dbContextFactory.CreateDbContextAsync();

            var existingAdmin = await context.Users
                .FirstOrDefaultAsync(u => u.Id == input.AdminId && u.Role == "admin");

            if (existingAdmin == null)
            {
                throw new Exception("Admin s navedenim ID-em ne postoji.");
            }

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

        public async Task<string> Login(
            [GraphQLNonNullType] string email,
            [GraphQLNonNullType] string password,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory,
            [Service] JwtService jwtService)
        {
            await using var context = await dbContextFactory.CreateDbContextAsync();

            var user = await context.Users
                .FirstOrDefaultAsync(u => u.Email == email && u.Password == password);

            if (user == null)
            {
                throw new GraphQLException("Pogrešan email ili lozinka.");
            }

            return jwtService.GenerateToken(user);
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