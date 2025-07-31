using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HotChocolate;
using HotChocolate.Types;
using TerminoApp.Data;
using TerminoApp.Models;
using TerminoApp.GraphQL.Inputs;
using TerminoApp.Services;
using Microsoft.AspNetCore.Http;
using System.Linq;
using System.Security.Claims;

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

            var existingUser = await context.Users.FirstOrDefaultAsync(u => u.Email == input.Email);
            if (existingUser != null)
            {
                throw new GraphQLException("Korisnik s tim emailom već postoji.");
            }

            var user = new User
            {
                Name = input.Name,
                Email = input.Email,
                Phone = input.Phone,
                Role = input.Role,
                Password = input.Password
            };

            await context.Users.AddAsync(user);
            await context.SaveChangesAsync();
            return user;
        }

        public async Task<Service> AddService(
            [GraphQLName("input")] ServiceInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory,
            [Service] IHttpContextAccessor contextAccessor)
        {
            var httpContext = contextAccessor.HttpContext;
            var userClaims = httpContext?.User;

            Console.WriteLine("🔐 IsAuthenticated: " + userClaims?.Identity?.IsAuthenticated);
            foreach (var claim in userClaims?.Claims ?? Enumerable.Empty<Claim>())
            {
                Console.WriteLine($"🧩 Claim: {claim.Type} = {claim.Value}");
            }

            if (userClaims == null ||
                !(userClaims.Identity?.IsAuthenticated ?? false) ||
                userClaims.FindFirst(ClaimTypes.Role)?.Value != "admin")
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
                AdminId = input.AdminId,
                DurationInMinutes = input.DurationInMinutes
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

            var service = await context.Services.FirstOrDefaultAsync(s => s.Id == input.ServiceId);
            if (service == null)
            {
                throw new Exception("Usluga ne postoji.");
            }

            var trajanje = TimeSpan.FromMinutes(service.DurationInMinutes);
            var noviPocetak = input.DateTime;
            var noviKraj = input.DateTime.Add(trajanje);

            var preklapanje = await context.Reservations
                .Where(r => r.ServiceId == input.ServiceId)
                .AnyAsync(r =>
                    input.DateTime < r.DateTime.AddMinutes(service.DurationInMinutes) &&
                    noviKraj > r.DateTime);

            if (preklapanje)
            {
                throw new GraphQLException("Termin se preklapa s postojećom rezervacijom.");
            }

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