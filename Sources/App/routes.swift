import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.get { req async throws in
//        try await req.view.render("index", ["title": "Welcome"])
//    }
    
//    let htmlProtected = app.grouped([
//        app.sessions.middleware,
//        User.sessionAuthenticator(),
//    ])

    try app.register(collection: IndexPageController())
    try app.register(collection: CreatePageController(app))
    try app.register(collection: MyCardsPageController(app))
    try app.register(collection: GalleryPageController(app))
    try app.register(collection: AboutPageController(app))
    try app.register(collection: CardController(app))
    try app.register(collection: UserController(app))
}
