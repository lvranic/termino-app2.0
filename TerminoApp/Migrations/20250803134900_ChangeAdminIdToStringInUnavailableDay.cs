using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TerminoApp.Migrations
{
    /// <inheritdoc />
    public partial class ChangeAdminIdToStringInUnavailableDay : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UnavailableDays_Users_AdminId",
                table: "UnavailableDays");

            migrationBuilder.DropIndex(
                name: "IX_UnavailableDays_AdminId",
                table: "UnavailableDays");

            migrationBuilder.AlterColumn<string>(
                name: "AdminId",
                table: "UnavailableDays",
                type: "text",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddColumn<int>(
                name: "AdminId1",
                table: "UnavailableDays",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_UnavailableDays_AdminId1",
                table: "UnavailableDays",
                column: "AdminId1");

            migrationBuilder.AddForeignKey(
                name: "FK_UnavailableDays_Users_AdminId1",
                table: "UnavailableDays",
                column: "AdminId1",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UnavailableDays_Users_AdminId1",
                table: "UnavailableDays");

            migrationBuilder.DropIndex(
                name: "IX_UnavailableDays_AdminId1",
                table: "UnavailableDays");

            migrationBuilder.DropColumn(
                name: "AdminId1",
                table: "UnavailableDays");

            migrationBuilder.AlterColumn<int>(
                name: "AdminId",
                table: "UnavailableDays",
                type: "integer",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

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
    }
}
