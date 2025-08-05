using System;

#nullable enable

namespace TerminoApp.GraphQL.Inputs
{
    public class UnavailableDayInput
    {
        public DateTime Date { get; set; }

        // Promijenjeno s int na string
        public int AdminId { get; set; }
    }
}