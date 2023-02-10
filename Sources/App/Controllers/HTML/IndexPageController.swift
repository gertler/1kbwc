//
//  IndexPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct IndexPageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.post("users", use: create)
        
        let credentialsProtectedRoute = routes.grouped([
            User.credentialsAuthenticator(),
        ])
        credentialsProtectedRoute.post("login", use: login)
    }

    /// Presents the "/" route (home page) to the user with context parsed from the request query
    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        var publicUser: User.Public?
        var context = IndexContext(
            title: "Welcome"
        )
        
        if let _user = user {
            publicUser = User.Public.init(_user)
            context.user = publicUser
        }

        let failedQuery = try req.query.decode(IndexRedirectQuery.self)
        if failedQuery.error ?? false {
            switch failedQuery.reason {
            case .loginFailedWrongPassword:
                context.loginErrorMessage = "Wrong password"
                context.loginUsernameFieldFill = failedQuery.usernameFill
                
            case .signupFailedPasswordsMismatch:
                context.signupErrorMessage = "The passwords did not match"
                context.signupUsernameFieldFill = failedQuery.usernameFill
                
            case .loginVapor(let string):
                context.loginErrorMessage = string
                context.loginUsernameFieldFill = failedQuery.usernameFill
                
            case .signupVapor(let string):
                context.signupErrorMessage = string
                context.signupUsernameFieldFill = failedQuery.usernameFill
                
            case .none:
                break
            }
        }
        
        return try await req.view.render("index", context)
    }
    
    /// An existing user attempting to login using credentials in the request body using `User.credentialsAuthenticator()`
    func login(req: Request) async throws -> Response {
        req.logger.debug("Attempting to authenticate login user")
        let user = req.auth.get(User.self)
        
        if let _user = user {
            req.logger.debug("Successfully authenticated user: \(_user.username)")
        } else {
            req.logger.debug("Failed to authenticate!")
            struct LoginUser: Content { var username: String; var password: String }
            let loginUser = try? req.content.decode(LoginUser.self)
            return try redirectWithParams(req: req, reason: .loginFailedWrongPassword, usernameFill: loginUser?.username)
        }
        
        return req.redirect(to: "/")
    }
    
    /// A new user is signing up via a `User.Create` in the request body
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
    
    private func redirectWithParams(_ to: String = "/",
                                    req: Request,
                                    error: Bool = true,
                                    reason: IndexRedirectFailureReason,
                                    usernameFill: String? = nil) throws -> Response {
        let params = IndexPageController.IndexRedirectQuery(error: error, reason: reason, usernameFill: usernameFill)
        let queryString = try req.redirectService.extractParams(params: params)
        return req.redirect(to: "\(to)\(queryString)")
    }
}

extension IndexPageController {
    struct IndexContext: Encodable {
        var title: String
        var user: User.Public?
        var loginErrorMessage: String?
        var signupErrorMessage: String?
        var loginUsernameFieldFill: String?
        var signupUsernameFieldFill: String?
    }
}
