//
//  MyCardsPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct MyCardsPageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped([
            User.redirectMiddleware(path: "/")
        ])
        
        protected.get("my-cards", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        var publicUser: User.Public?
        if let _user = user {
            publicUser = User.Public.init(_user)
        }
        
        let cards = try await Card.query(on: req.db).with(\.$user).all()
        let publicCards = cards.map({ Card.Public.init($0) })
        
        let context = MyCardsContext(
            title: "My Cards",
            user: publicUser,
            cards: publicCards
        )
        return try await req.view.render("my-cards", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct MyCardsContext: Encodable {
    var title: String
    var user: User.Public?
    var cards: [Card.Public]?
}
