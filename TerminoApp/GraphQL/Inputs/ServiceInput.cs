using System;
#nullable enable

namespace TerminoApp.GraphQL.Inputs
{
    public class ServiceInput
    {
        public string Name { get; set; } = default!;
        public string Description { get; set; } = default!;
        public int DurationMinutes { get; set; }
        public decimal Price { get; set; }
    }
}