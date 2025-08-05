using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using TerminoApp.Data;
using TerminoApp.GraphQL;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using TerminoApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Omogućavamo pristup kontekstu HTTP zahtjeva
builder.Services.AddHttpContextAccessor();

// Registriramo JWT servis
builder.Services.AddScoped<JwtService>();

// VAŽNO: Registriramo PooledDbContextFactory jer ga koristiš u Mutation.cs
builder.Services.AddPooledDbContextFactory<AppDbContext>(options =>
{
    var connStr = builder.Configuration.GetConnectionString("DefaultConnection");
    Console.WriteLine($"🔌 Connection string: {connStr}");
    options.UseNpgsql(connStr);
});

// JWT autentikacija
builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        var jwtSettings = builder.Configuration.GetSection("JwtSettings");
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwtSettings["Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings["Key"]!)),
            ValidateLifetime = true,
            NameClaimType = "email",
            RoleClaimType = "role"
        };
    });

builder.Services.AddAuthorization();

// GraphQL konfiguracija
builder.Services
    .AddGraphQLServer()
    .AddQueryType<Query>()
    .AddType<UserQueries>()
    .AddType<UnavailableDayQueries>()
    .AddMutationType<Mutation>();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();
app.MapGraphQL();

app.Run();