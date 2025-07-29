using TerminoApp.Models;

namespace TerminoApp.Models
{
    public class Service
    {
        public int Id { get; set; }
        public string Name { get; set; } = default!;
        public string Description { get; set; } = default!;
        public string Address { get; set; } = default!;
        public string WorkingHours { get; set; } = default!;
        public int AdminId { get; set; }

        public User? Admin { get; set; }
    }
}