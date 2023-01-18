import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let dbPasswordFilename = Environment.get("DATABASE_PASSWORD_FILE") ?? ""
    let dbPasswordFile = URL.init(fileURLWithPath: dbPasswordFilename)
    let dbPassword = try String.init(contentsOf: dbPasswordFile)

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "",
        password: dbPassword,
        database: Environment.get("DATABASE_NAME") ?? ""
    ), as: .psql)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
