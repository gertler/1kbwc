//
//  UserAuthentication.swift
//  
//
//  Created by Harrison Gertler on 1/27/23.
//

import Vapor
import Fluent

// Used to create a new User
extension User {
    struct Create: Content {
        var username: String
        var password: String
        var confirmPassword: String
    }
}

// Used to validate the creation of a new User
extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty && .alphanumeric)
        validations.add("password", as: String.self, is: .count(16...) && .ascii)
    }
}

// Used to perform Basic authentication when logging in a User
extension User: ModelAuthenticatable,
                ModelCredentialsAuthenticatable {
    static var usernameKey: KeyPath<User, Field<String>> {
        \User.$username
    }
    
    static var passwordHashKey: KeyPath<User, Field<String>> {
        \User.$passwordHash
    }
    
    func verify(password: String) throws -> Bool {
        // NOTE: Bcrypt is used to encrypt password in UserController.swift:create(req: Request)
        // This is defined in configure.swift via `app.passwords.use(.bcrypt)`
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

// Allows Fluent Model to enable session authentication through User.sessionAuthenticator()
extension User: ModelSessionAuthenticatable { }

// Makes it so we can use req.auth.require(Admin.self) to authenticate
// This makes use of the fact that User can be found via req.auth.require(User.self)
extension Admin: Authenticatable { }

// This is a simple Authenticator that checks the User.userRoles contains .admin
extension Admin {
    struct AdminAuthenticator: AsyncRequestAuthenticator {
        func authenticate(request: Vapor.Request) async throws {
            let user = try request.auth.require(User.self)
            guard user.userRoles.contains(.admin) else {
                return
            }
            request.auth.login(Admin(user: user))
        }
    }
}

