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
    let dbUsernameFilename = Environment.get("DATABASE_USERNAME_FILE") ?? ""
    let dbUsernameFile = URL.init(fileURLWithPath: dbUsernameFilename)
    let dbUsername = try String.init(contentsOf: dbUsernameFile)
    
    let dbPasswordFilename = Environment.get("DATABASE_PASSWORD_FILE") ?? ""
    let dbPasswordFile = URL.init(fileURLWithPath: dbPasswordFilename)
    let dbPassword = try String.init(contentsOf: dbPasswordFile)
    
    let dbNameFilename = Environment.get("DATABASE_NAME_FILE") ?? ""
    let dbNameFile = URL.init(fileURLWithPath: dbNameFilename)
    let dbName = try String.init(contentsOf: dbNameFile)

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
    app.routes.defaultMaxBodySize = "500kb"

    // register routes
    try routes(app)
}

private func addMigrations(app: Application) {
    app.migrations.add(CreateCard())
    app.migrations.add(CreateUser())
}
