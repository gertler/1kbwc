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
            let loginFailed = IndexRedirectFailure(error: true, reason: .loginFailedWrongPassword, usernameFill: loginUser?.username)
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
            var desc: String
            switch self {
            case .loginFailedWrongPassword:
                desc = "loginFailedWrongPassword"
            case .signupFailedPasswordsMismatch:
                desc = "signupFailedPasswordsMismatch"
            case .loginVapor(let string):
                desc = "loginVapor$\(string)"
            case .signupVapor(let string):
                desc = "signupVapor$\(string)"
            }
            return desc
        }
        
        func encode(to encoder: Encoder) throws {
            var _container = encoder.singleValueContainer()
            try _container.encode(self.description)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if string.hasPrefix("loginVapor$") {
                let i = string.index(after: string.firstIndex(of: "$")!)
                let a0 = String.init(string.suffix(from: i))
                self = .loginVapor(a0)
            } else if string.hasPrefix("signupVapor$") {
                let i = string.index(after: string.firstIndex(of: "$")!)
                let a0 = String.init(string.suffix(from: i))
                self = .signupVapor(a0)
            } else {
                switch string {
                case IndexRedirectFailureReason.loginFailedWrongPassword.description:
                    self = .loginFailedWrongPassword
                case IndexRedirectFailureReason.signupFailedPasswordsMismatch.description:
                    self = .signupFailedPasswordsMismatch
                default:
                    throw DecodingError.keyNotFound(string.codingKey, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Unexpected key found, invalid enum value."))
                }
            }
        }
        
        case loginFailedWrongPassword
        case signupFailedPasswordsMismatch
        case loginVapor(String)
        case signupVapor(String)
    }
    
    struct LoginUser: Content {
        var username: String
        var password: String
    }
}
