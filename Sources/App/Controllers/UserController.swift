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
        users.post(use: create)
        users.group(":userID") { user in
            user.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [UserPublic] {
        let users = try await User.query(on: req.db).all()
        return users.map { UserPublic($0) }
    }

    func create(req: Request) async throws -> UserPublic {
        let userPublic = try req.content.decode(UserPublic.self)
        guard let pwd = userPublic.password else {
            throw Abort(.badRequest)
        }
        
        let digest = try req.password.hash(pwd)
        let user = User(username: userPublic.username, passwordHash: digest)
        try await user.save(on: req.db)
        return UserPublic(user)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
}
