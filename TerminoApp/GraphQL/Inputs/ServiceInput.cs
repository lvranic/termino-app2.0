using System;
#nullable enable

namespace TerminoApp.GraphQL.Inputs
{
    public class ServiceInput
    {
        public string Name { get; set; } = default!;
        public string Description { get; set; } = default!;
        public string Address { get; set; } = default!;
        public string WorkingHours { get; set; } = default!;
        public int AdminId { get; set; }
    }
}