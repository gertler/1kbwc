import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Get the db credentials from environment variables
    // This is done this way to work with docker compose secrets, which reads from files, not Strings
    let dbUsername = try Environment.unwrapSecretFile("DATABASE_USERNAME_FILE")
    let dbPassword = try Environment.unwrapSecretFile("DATABASE_PASSWORD_FILE")
    let dbName = try Environment.unwrapSecretFile("DATABASE_NAME_FILE")

    //
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: dbUsername,
        password: dbPassword,
        database: dbName
    ), as: .psql)

    addMigrations(app: app)

    app.views.use(.leaf)
    app.passwords.use(.bcrypt)
    app.middleware.use(app.sessions.middleware)
//    app.routes.defaultMaxBodySize = "16kb"

    // register routes
    try routes(app)
}

private func addMigrations(app: Application) {
    for migration in Migrations.shared {
        app.migrations.add(migration)
    }
}
