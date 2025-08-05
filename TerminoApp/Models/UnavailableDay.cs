using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TerminoApp.Models
{
    public class UnavailableDay
    {
        public int Id { get; set; }

        [Required]
        public DateTime Date { get; set; }

        [Required]
        public int AdminId { get; set; } // Ispravljeno s 'string' na 'int'

        [ForeignKey("AdminId")]
        public User Admin { get; set; } = null!;
    }
}