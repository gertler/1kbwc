//
//  IndexPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct IndexPageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        
        let credentialsProtectedRoute = routes.grouped([
            User.credentialsAuthenticator(),
        ])
        credentialsProtectedRoute.post("login", use: login)
    }

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

        let failedQuery = try req.query.decode(LoginFailed.self)
        if let _ = failedQuery.loginFailed {
            context.errorMessage = "Unknown error occurred!"
            if let _ = failedQuery.wrongPassword {
                context.errorMessage = "Password was incorrect!"
            }
        }
        
        return try await req.view.render("index", context)
    }
    
    func login(req: Request) async throws -> Response {
        req.logger.debug("Attempting to authenticate login user")
        let user = req.auth.get(User.self)
        
        if let _user = user {
            req.logger.debug("Successfully authenticated user: \(_user.username)")
        } else {
            req.logger.debug("Failed to authenticate!")
            let loginFailed = LoginFailed(loginFailed: true, wrongPassword: true)
            let redirectParams = try req.redirectService.extractParams(params: loginFailed)
            return req.redirect(to: "/\(redirectParams)")
        }
        
        return req.redirect(to: "/")
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct IndexContext: Encodable {
    var title: String
    var user: User.Public?
    var errorMessage: String?
}

struct LoginFailed: Content {
    var loginFailed: Bool?
    var wrongPassword: Bool?
}
