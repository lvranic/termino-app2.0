#nullable enable
namespace TerminoApp.GraphQL.Inputs;

public class UserInput
{
    public string Name { get; set; } = default!;
    public string Email { get; set; } = default!;
    public string Phone { get; set; } = default!;
    public string Role { get; set; } = default!;
    public string Password { get; set; } = default!;
}