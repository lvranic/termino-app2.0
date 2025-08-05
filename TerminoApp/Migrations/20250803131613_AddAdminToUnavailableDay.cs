using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminoApp.Migrations
{
    /// <inheritdoc />
    public partial class AddAdminToUnavailableDay : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AdminId",
                table: "UnavailableDays",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_UnavailableDays_AdminId",
                table: "UnavailableDays",
                column: "AdminId");

            migrationBuilder.AddForeignKey(
                name: "FK_UnavailableDays_Users_AdminId",
                table: "UnavailableDays",
                column: "AdminId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UnavailableDays_Users_AdminId",
                table: "UnavailableDays");

            migrationBuilder.DropIndex(
                name: "IX_UnavailableDays_AdminId",
                table: "UnavailableDays");

            migrationBuilder.DropColumn(
                name: "AdminId",
                table: "UnavailableDays");
        }
    }
}
