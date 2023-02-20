//
//  CardController.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent
import Vapor
import SotoCore

struct CardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cards = routes.grouped("cards")
        cards.get(use: index)
        cards.get(":cardID", use: cardImage)
        
        let protected = cards.grouped([
            User.redirectMiddleware(path: "/")
        ])
        protected.on(.POST, body: .collect(maxSize: "1mb"), use: create)
        protected.delete(":cardID", use: delete)
    }

    func index(req: Request) async throws -> [Card.Public] {
        // NOTE: .with(\.$user) eager loads that model from the db to access all of User fields when parsing
        let cards = try await Card.query(on: req.db).with(\.$user).all()
        return try cards.map({ try Card.Public.init($0) })
    }

    func create(req: Request) async throws -> Card {
        let cardCreate = try req.query.decode(Card.Create.self)
        let user = try req.auth.require(User.self)
        guard let userID = user.id else {
            throw Abort(.internalServerError)
        }
        let card = Card.init(title: cardCreate.title, userID: userID)
        
        // Try to upload file to S3
        guard let cardDataBuffer = req.body.data else {
            req.logger.warning("No body data in request")
            throw Abort(.badRequest)
        }
        
        let key = try await uploadPNG(for: req, data: cardDataBuffer, cardTitle: card.title)
        card.s3Filepath = key
        
        // Try to save card in db
        try await card.save(on: req.db)
        
        return card
    }
    
    func cardImage(req: Request) async throws -> ClientResponse {
        guard let id = req.parameters.get("cardID") as UUID?,
              let card = try await Card.find(id, on: req.db),
              let s3Filepath = card.s3Filepath else {
            throw Abort(.notFound)
        }
        
        req.logger.debug("s3Filepath: \(s3Filepath)")
        let url = try req.objectURIFor(s3Filepath)

        req.logger.debug("Unsigned URL for card image: \(url.absoluteString)")
        let signedURL = try await req.aws.s3.signURL(url: url, httpMethod: .GET, expires: .hours(1))
        req.logger.debug("Signed URL for card image: \(signedURL.absoluteString)")
        let response = try await req.client.get("\(signedURL.absoluteString)")
        req.logger.debug("Response: \(response.status)")
        return response
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        guard let id = req.parameters.get("cardID") as UUID?,
              let card = try await Card.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard card.$user.id == userID else {
            throw Abort(.unauthorized, reason: "User is not the card's owner")
        }
        
        try await card.delete(on: req.db)
        return .noContent
    }
}
