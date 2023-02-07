import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import QueuesRedisDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Get the db credentials from environment variables
    // This is done this way to work with docker compose secrets, which reads from files, not Strings
    let dbUsername = try Environment.unwrapSecretFile("DATABASE_USERNAME_FILE")
    let dbPassword = try Environment.unwrapSecretFile("DATABASE_PASSWORD_FILE")
    let dbName = try Environment.unwrapSecretFile("DATABASE_NAME_FILE")

    // PostgreSQL Database Connection
    app.logger.notice("Attempting to connect to database")
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: dbUsername,
        password: dbPassword,
        database: dbName
    ), as: .psql)
    app.logger.debug("Successfully connected to database")

    // Database Migrations
    addMigrations(app: app)
    
    // Redis Connection (for Queue Jobs)
    app.logger.notice("Attempting to connect to redis for queues driver")
    app.queues.use(.redis(try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "",
        port: Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? RedisConnection.Configuration.defaultPort
    )))
    app.logger.debug("Successfully connected to redis")

    // Additional Configuration
    app.views.use(.leaf)
    app.passwords.use(.bcrypt)
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    app.queues.schedule(CleanupUserTokensJob())
        .daily()
        .at(.midnight)
    // Run in-process workers for scheduled jobs
    try app.queues.startScheduledJobs()

    // Register Routes
    try routes(app)
}

private func addMigrations(app: Application) {
    for migration in Migrations.shared {
        app.migrations.add(migration)
    }
}
