using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using TerminoApp.Data;
using TerminoApp.GraphQL;

var builder = WebApplication.CreateBuilder(args);

// Koristi PooledDbContextFactory jer koristiš [UseDbContext]
builder.Services.AddPooledDbContextFactory<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// GraphQL konfiguracija
builder.Services
    .AddGraphQLServer()
    .AddQueryType<Query>()
    .AddMutationType<Mutation>()
    .AddFiltering()
    .AddSorting()
    .ModifyRequestOptions(opt => opt.IncludeExceptionDetails = true); // za debugging

var app = builder.Build();

app.MapGraphQL(); // GraphQL endpoint

app.Run();