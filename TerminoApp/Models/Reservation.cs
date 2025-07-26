using System;

namespace TerminoApp.Models
{
    public class Reservation
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int ServiceId { get; set; }
        public DateTime DateTime { get; set; }

        public User User { get; set; } = default!;
        public Service Service { get; set; } = default!;
    }
}