using System;

namespace TerminoApp.GraphQL.Inputs
{
    public class UserInput
    {
        public string Name { get; set; } = default!;
        public string Email { get; set; } = default!;
        public string? Phone { get; set; }
        public string Role { get; set; } = default!;
    }
}