using Microsoft.EntityFrameworkCore;
using TerminoApp.Models;

namespace TerminoApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; } = default!;
        public DbSet<Service> Services { get; set; } = default!;
        public DbSet<Reservation> Reservations { get; set; } = default!;
        public DbSet<UnavailableDay> UnavailableDays { get; set; } = default!;
    }
}