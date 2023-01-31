import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Welcome"])
    }

    try app.register(collection: CreatePageController(app))
    try app.register(collection: CardController())
    try app.register(collection: UserController(app))
}
