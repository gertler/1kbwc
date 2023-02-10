//
//  UserController.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        
        let protected = users.grouped([
            User.redirectMiddleware(path: "/")
        ])
        protected.get("me", use: me)
        protected.post("logout", use: logout)
    }
    
    func logout(req: Request) async throws -> Response {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.expectationFailed, reason: "User is not logged in")
        }
        req.logger.debug("Attempting to logout user: \(user.username)")
        req.auth.logout(User.self)
        req.logger.debug("Successfully logged out user: \(user.username)")
        return req.redirect(to: "/")
    }

    func index(req: Request) async throws -> [User.Public] {
        let users = try await User.query(on: req.db).all()
        return users.map { User.Public.init($0) }
    }
    
    func me(req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        return User.Public.init(user)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
