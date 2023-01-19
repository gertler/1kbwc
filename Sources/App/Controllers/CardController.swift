//
//  CardController.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent
import Vapor

struct CardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cards = routes.grouped("cards")
        cards.get(use: index)
        cards.post(use: create)
        cards.group(":cardID") { card in
            card.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Card] {
        try await Card.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Card {
        let card = try req.content.decode(Card.self)
        try await card.save(on: req.db)
        return card
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let card = try await Card.find(req.parameters.get("cardID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await card.delete(on: req.db)
        return .noContent
    }
}
