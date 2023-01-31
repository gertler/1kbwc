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
        validations.add("username", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(16...))
    }
}

// Used to perform Basic authentication when logging in a User
extension User: ModelAuthenticatable {
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

// Used to generate authentication tokens for a logged-in User
extension User {
    private var tokenLength: Int { 32 }
    
    func generateToken(logger: Logger? = nil) throws -> UserToken {
        let value = [UInt8].random(count: self.tokenLength).base64
        logger?.debug("Generated new user token: \(value)")
        return try UserToken.init(
            value: value,
            userID: self.requireID()
        )
    }
}

// Used to manage authentication tokens
final class UserToken: Model, Content {
    static let schema = "user_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    // When this UserToken was created.
    @Timestamp(key: "issued_at", on: .create)
    var issuedAt: Date?

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

// Declare Data Transferrable Objects
// https://docs.vapor.codes/fluent/model/#data-transfer-object
extension UserToken {
    /// DTO to be sent to the client that hides information like the password hash
    struct Public: Content {
        var userID: UUID?
        var token: String
        
        init(_ userToken: UserToken) {
            self.userID = userToken.$user.id
            self.token = userToken.value
        }
    }
}

// Used with .authenticator() to protect routes using User Tokens
extension UserToken: ModelTokenAuthenticatable {
    static var valueKey = \UserToken.$value
    static var userKey = \UserToken.$user
    
    var isValid: Bool {
        guard let timeSince = self.issuedAt?.timeIntervalSinceNow else {
            return false
        }
        return abs(timeSince) < 15 // 15 seconds
    }
}

// Allows Fluent Model to enable session authentication through User.sessionAuthenticator()
extension User: ModelSessionAuthenticatable { }
