using System;
#nullable enable

namespace TerminoApp.GraphQL.Inputs
{
    public class ReservationInput
    {
        public string? UserId { get; set; }          // može biti null jer Firebase koristi string ID
        public string ServiceId { get; set; } = null!; // non-nullable, ali inicijaliziran sa null!
        public string Time { get; set; } = null!;      // isto tako
        public int Hour { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime Date { get; set; }
    }
}