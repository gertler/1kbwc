import Fluent
import SotoCore
import SotoS3
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
    guard let dbUsername = Environment.get(.db_user),
          let dbPassword = Environment.get(.db_pass),
          let dbName = Environment.get(.db_name) else {
        fatalError("Postgres DB credentials are missing. Please provide that information via Environment variables. See README.md.")
    }

    // PostgreSQL Database Connection
    app.logger.notice("Attempting to connect to database")
    app.databases.use(.postgres(
        hostname: Environment.get(.db_host) ?? "",
        port: Environment.get(.db_port).flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
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
        hostname: Environment.get(.redis_host) ?? "",
        port: Environment.get(.redis_port).flatMap(Int.init(_:)) ?? RedisConnection.Configuration.defaultPort
    )))
    app.logger.debug("Successfully connected to redis")

    // Additional Configuration
    app.views.use(.leaf)
    app.passwords.use(.bcrypt)
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    
    // AWS Configure
    app.aws.client = try generateAWSClient(app: app)
    let region = Environment.get(.s3_region).flatMap(Region.init(awsRegionName:)) ?? .useast1
    app.aws.s3 = S3(client: app.aws.client, region: region)
    app.aws.s3Bucket = Environment.get(.s3_bucket) ?? ""
    if app.aws.s3Bucket.isEmpty {
        fatalError("S3 Bucket Name is missing. Use application.aws.s3Bucket = ...")
    }

    // Register Routes
    try routes(app)
}

private func addMigrations(app: Application) {
    for migration in Migrations.shared {
        app.migrations.add(migration)
    }
}

private func generateAWSClient(app: Application) throws -> AWSClient {
    app.logger.notice("Attempting to create AWS Client via static credentials")
    guard let accessKeyID = Environment.get(.aws_key),
          let secretAccessKey = Environment.get(.aws_secret_key) else {
        fatalError("AWS credentials are missing. Please provide that information via Environment variables. See README.md.")
    }
    let client = AWSClient(credentialProvider: .static(accessKeyId: accessKeyID, secretAccessKey: secretAccessKey),
                           httpClientProvider: .shared(app.http.client.shared))
    app.logger.debug("Successfully created AWS Client")
    return client
}
