import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import GraphQLKit
import GraphiQLVapor
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(.sqlite(.memory), as: .sqlite)

    // TODO: - Add Postgres after testing sqlite in memory
    //    app.databases.use(.postgres(
    //        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    //        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
    //        username: Environment.get("DATABASE_USERNAME") ?? "vn53uts",
    //        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
    //        database: Environment.get("DATABASE_NAME") ?? "medications" // postgres
    //    ), as: .psql)

    app.migrations.add(MigrateCustomerMedications()) // !!! must be first
    app.migrations.add(MigrateMedications())

    app.logger.logLevel = .debug

    try app.autoMigrate().wait()

    app.register(graphQLSchema: schema, withResolver: Resolver())

    // Enable GraphiQL web page to send queries to the GraphQL endpoint.
    if !app.environment.isRelease {
        app.enableGraphiQL()
    }
    
}
