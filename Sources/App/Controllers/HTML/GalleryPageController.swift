//
//  GalleryPageController.swift
//  
//
//  Created by Harrison Gertler on 2/2/23.
//

import Fluent
import Vapor

struct GalleryPageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("gallery", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        var publicUser: User.Public?
        if let _user = user {
            publicUser = User.Public.init(_user)
        }
        
        let cardsPrivate = try await Card.query(on: req.db)
            .with(\.$user)
            .sort(\.$createdAt, .descending)
            .range(..<5)
            .all()
        let cardsPublic = try cardsPrivate.map { try Card.Public.init($0) }
        
        let context = GalleryContext(
            title: "Gallery",
            user: publicUser,
            cards: cardsPublic
        )
        return try await req.view.render("gallery", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct GalleryContext: Encodable {
    var title: String
    var user: User.Public?
    var cards: [Card.Public]?
}
