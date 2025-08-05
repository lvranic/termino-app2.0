using Microsoft.EntityFrameworkCore;
using TerminoApp.Models;
using System;

namespace TerminoApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
            Console.WriteLine("✅ AppDbContext je uspješno instanciran.");
        }

        public DbSet<User> Users { get; set; } = default!;
        public DbSet<Service> Services { get; set; } = default!;
        public DbSet<Reservation> Reservations { get; set; } = default!;
        public DbSet<UnavailableDay> UnavailableDays { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Service>()
                .HasOne(s => s.Admin)
                .WithMany()
                .HasForeignKey(s => s.AdminId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<UnavailableDay>()
                .HasOne(ud => ud.Admin)
                .WithMany()
                .HasForeignKey(ud => ud.AdminId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}