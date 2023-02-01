//
//  UserController.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
//        users.group(":userID") { user in
//            user.delete(use: delete)
//        }
        
        let passwordProtected = users.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
        
        let protected = users.grouped([
            app.sessions.middleware,
            User.sessionAuthenticator(),
            UserToken.authenticator(),
//            User.redirectMiddleware(path: "/")
            User.guardMiddleware()
        ])
        protected.get("me", use: me)
        protected.post("logout", use: logout)
    }
    
    func login(req: Request) async throws -> UserToken.Public {
        req.logger.debug("Attempting to authenticate login user")
        let user = try req.auth.require(User.self)
        req.logger.debug("Successfully authenticated user: \(user.username)")
        req.logger.debug("Attempting to generate a user token")
        let token = try user.generateToken(logger: req.logger)
        try await token.save(on: req.db)
        req.logger.debug("Successfully saved a new user token: \(token.value)")
        return UserToken.Public.init(token)
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
        return users.map { User.Public($0) }
    }
    
    func me(req: Request) async throws -> User.Public {
        let user = try req.auth.require(User.self)
        return User.Public.init(user)
    }

    func create(req: Request) async throws -> User.Public {
        // Run validations declared in UserAuthentication.swift
        try User.Create.validate(content: req)
        // Decode create-user request as User.Create struct
        let create = try req.content.decode(User.Create.self)
        // Test if password and confirmPassword match; otherwise, send error
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        // Let Fluent and Vapor handle password storage
        let digest = try req.password.hash(create.password)
        let user = User(username: create.username, passwordHash: digest)
        try await user.save(on: req.db)
        return User.Public.init(user)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: req.db)
        return .noContent
    }
    
    init(_ app: Application) {
        self.app = app
    }
}
