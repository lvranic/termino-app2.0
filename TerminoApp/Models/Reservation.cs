using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

#nullable enable

namespace TerminoApp.Models
{
    public class Reservation
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = default!;

        [Required]
        public string ServiceId { get; set; } = default!;

        [Required]
        public DateTime Date { get; set; }

        [Required]
        public int Hour { get; set; }

        [Required]
        public int DurationMinutes { get; set; }

        [Required]
        public string Time { get; set; } = default!;

        public User User { get; set; } = default!;
        public Service Service { get; set; } = default!;
    }
}