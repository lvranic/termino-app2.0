using System;

namespace TerminoApp.GraphQL.Inputs
{
    public class ReservationInput
    {
        public int UserId { get; set; }
        public int ServiceId { get; set; }
        public DateTime DateTime { get; set; }
    }
}