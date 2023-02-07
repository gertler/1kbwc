//
//  CardController.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent
import Vapor

struct CardController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        let cards = routes.grouped("cards")
        
        let protected = cards.grouped([
            app.sessions.middleware,
            User.sessionAuthenticator(),
            UserToken.authenticator(),
            User.guardMiddleware()
        ])
        
        cards.get(use: index)
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
        let key = try await req.awsService.uploadPNG(cardDataBuffer, cardTitle: card.title, logger: req.logger)
        card.s3Filepath = key
        
        // Try to save card in db
        try await card.save(on: req.db)
        
        return card
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        guard let id = req.parameters.get("cardID") as UUID?,
              let card = try await Card.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard card.$user.id == userID else {
            throw Abort(.unauthorized)
        }
        
        try await card.delete(on: req.db)
        return .noContent
    }
    
    init(_ app: Application) {
        self.app = app
    }
}
