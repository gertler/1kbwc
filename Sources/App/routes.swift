import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.get { req async throws in
//        try await req.view.render("index", ["title": "Welcome"])
//    }
    
    let htmlProtected = app.grouped([
        app.sessions.middleware,
        User.sessionAuthenticator(),
        UserToken.authenticator(),
//        User.redirectMiddleware(path: "/")
    ])

    try htmlProtected.register(collection: IndexPageController(app))
    try htmlProtected.register(collection: CreatePageController(app))
    try htmlProtected.register(collection: MyCardsPageController(app))
    try htmlProtected.register(collection: AboutPageController(app))
    try app.register(collection: CardController(app))
    try app.register(collection: UserController(app))
}
