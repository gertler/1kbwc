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

    // Used for Web creation
    func create(req: Request) async throws -> Response {
        // Decode create-user request as User.Create struct
        let create = try req.content.decode(User.Create.self)
        
        // Run validations declared in UserAuthentication.swift
        do {
            try User.Create.validate(content: req)
        } catch let error as AbortError {
            return try redirectWithParams(req: req, reason: .signupVapor(error.reason), usernameFill: create.username)
        }
        
        // Test if password and confirmPassword match; otherwise, send error
        guard create.password == create.confirmPassword else {
            return try redirectWithParams(req: req, reason: .signupFailedPasswordsMismatch, usernameFill: create.username)
        }
        
        // Let Fluent and Vapor handle password storage
        let digest = try req.password.hash(create.password)
        let user = User(username: create.username, passwordHash: digest)
        try await user.save(on: req.db)
        // Login user by default
        req.auth.login(user)
        return req.redirect(to: "/")
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
    
    private func redirectWithParams(_ to: String = "/",
                                    req: Request,
                                    error: Bool = true,
                                    reason: IndexPageController.IndexRedirectFailureReason,
                                    usernameFill: String? = nil) throws -> Response {
        let params = IndexPageController.IndexRedirectFailure(error: error, reason: reason, usernameFill: usernameFill)
        let queryString = try req.redirectService.extractParams(params: params)
        return req.redirect(to: "\(to)\(queryString)")
    }
}
