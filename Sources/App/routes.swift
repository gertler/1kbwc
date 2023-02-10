import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: IndexPageController())
    try app.register(collection: CreatePageController())
    try app.register(collection: MyCardsPageController())
    try app.register(collection: GalleryPageController())
    try app.register(collection: AboutPageController())
    try app.register(collection: CardController())
    try app.register(collection: UserController(app))
}
