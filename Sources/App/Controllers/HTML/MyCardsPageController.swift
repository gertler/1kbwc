//
//  MyCardsPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct MyCardsPageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped([
            User.redirectMiddleware(path: "/")
        ])
        
        protected.get("my-cards", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = try req.auth.require(User.self)
        let publicUser = User.Public.init(user)
        let userID = try user.requireID()
        
        let cards = try await Card.query(on: req.db)
            .join(User.self, on: \Card.$user.$id == \User.$id)
            .filter(User.self, \.$id == userID)
            .with(\.$user)
            .all()
        let publicCards = try cards.map { try Card.Public.init($0) }
        
        let context = MyCardsContext(
            title: "My Cards",
            user: publicUser,
            cards: publicCards
        )
        return try await req.view.render("my-cards", context)
    }
}

struct MyCardsContext: Encodable {
    var title: String
    var user: User.Public?
    var cards: [Card.Public]?
}
