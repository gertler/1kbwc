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

        let failedQuery = try req.query.decode(IndexRedirectFailure.self)
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
    
    func login(req: Request) async throws -> Response {
        req.logger.debug("Attempting to authenticate login user")
        let user = req.auth.get(User.self)
        
        if let _user = user {
            req.logger.debug("Successfully authenticated user: \(_user.username)")
        } else {
            req.logger.debug("Failed to authenticate!")
            let loginUser = try? req.content.decode(LoginUser.self)
            let loginFailed = IndexRedirectFailure(error: true, reason: .loginFailedWrongPassword(""), usernameFill: loginUser?.username)
            let redirectParams = try req.redirectService.extractParams(params: loginFailed)
            return req.redirect(to: "/\(redirectParams)")
        }
        
        return req.redirect(to: "/")
    }
    
    init(_ app: Application) {
        self.app = app
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
    
    struct IndexRedirectFailure: Content {
        var error: Bool?
        var reason: IndexRedirectFailureReason?
        var usernameFill: String?
    }
    
    enum IndexRedirectFailureReason: Codable, CustomStringConvertible {
        var description: String {
            switch self {
            case .loginFailedWrongPassword(let string):
                return string
            case .signupFailedPasswordsMismatch(let string):
                return string
            case .loginVapor(let string):
                return string
            case .signupVapor(let string):
                return string
            }
        }
        
        case loginFailedWrongPassword(String)
        case signupFailedPasswordsMismatch(String)
        case loginVapor(String)
        case signupVapor(String)
    }
    
    struct LoginUser: Content {
        var username: String
        var password: String
    }
}
