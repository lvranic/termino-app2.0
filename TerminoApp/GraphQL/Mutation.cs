using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using HotChocolate;
using HotChocolate.Types;
using TerminoApp.Data;
using TerminoApp.Models;
using TerminoApp.Services;
using TerminoApp.GraphQL.Inputs;

namespace TerminoApp.GraphQL
{
    public class Mutation
    {
        public Mutation()
        {
            Console.WriteLine("🚀 Mutation klasa učitana.");
        }

        [GraphQLName("login")]
        public async Task<string> Login(
            [GraphQLNonNullType] string email,
            [GraphQLNonNullType] string password,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory,
            [Service] JwtService jwtService
        )
        {
            Console.WriteLine("🔐 Login mutacija pozvana!");

            try
            {
                await using var context = await dbContextFactory.CreateDbContextAsync();

                if (!context.Database.CanConnect())
                {
                    Console.WriteLine("❗ Nema konekcije s bazom podataka!");
                    throw new Exception("Neuspješno spajanje na bazu.");
                }

                var user = await context.Users
                    .FirstOrDefaultAsync(u => u.Email == email && u.Password == password);

                if (user == null)
                {
                    Console.WriteLine("❌ Korisnik nije pronađen!");
                    throw new GraphQLException("Pogrešan email ili lozinka.");
                }

                Console.WriteLine($"✅ Korisnik: {user.Email} (ID: {user.Id})");

                var token = jwtService.GenerateToken(user);

                Console.WriteLine($"🔑 Token: {token}");

                return token;
            }
            catch (Exception ex)
            {
                Console.WriteLine("❗ CATCH blok — greška u login:");
                Console.WriteLine($"💥 Poruka: {ex.Message}");
                Console.WriteLine($"📛 StackTrace: {ex.StackTrace}");
                throw;
            }
        }

        [GraphQLName("addReservation")]
        public async Task<Reservation> CreateReservation(
            [GraphQLNonNullType] ReservationInput input,
            [Service] IDbContextFactory<AppDbContext> dbContextFactory)
        {
            Console.WriteLine("🟢 POZVANA MUTACIJA addReservation");

            try
            {
                Console.WriteLine($"➡️ UserId: {input.UserId}");
                Console.WriteLine($"➡️ ServiceId: {input.ServiceId}");
                Console.WriteLine($"➡️ Date: {input.Date}");
                Console.WriteLine($"➡️ Time: {input.Time}");
                Console.WriteLine($"➡️ Hour: {input.Hour}");
                Console.WriteLine($"➡️ DurationMinutes: {input.DurationMinutes}");

                await using var context = await dbContextFactory.CreateDbContextAsync();

                var reservation = new Reservation
                {
                    UserId = input.UserId!,
                    ServiceId = input.ServiceId,
                    Time = input.Time,
                    Hour = input.Hour,
                    DurationMinutes = input.DurationMinutes,
                    Date = input.Date
                };

                context.Reservations.Add(reservation);
                await context.SaveChangesAsync();

                Console.WriteLine("✅ Rezervacija uspješno spremljena.");
                return reservation;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ GREŠKA: {ex.Message}");
                Console.WriteLine(ex.StackTrace);
                throw;
            }
        }
    }
}