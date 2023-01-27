import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Index!"])
    }
    
    app.get("create") { req async throws in
        try await req.view.render("create", ["title": "Create a Card"])
    }

    try app.register(collection: CardController())
    try app.register(collection: UserController())
}
