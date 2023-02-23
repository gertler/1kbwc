//
//  User.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "user_roles")
    var userRoles: UserRoles
    
    // When this User was created.
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // When this User was last updated.
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, username: String, passwordHash: String, userRoles: UserRoles = .noRoles) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
        self.userRoles = userRoles
    }
    
}

struct UserRoles: OptionSet, Codable {
    var rawValue: UInt64
    
    init(rawValue: UInt64) {
        self.rawValue = rawValue
    }
    
    init(from decoder: Decoder) throws {
        self.rawValue = try UInt64.init(from: decoder)
    }
    
    func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
    
    static let noRoles: Self = []
    // Right now, only admin is of any use
    static let admin         = Self.init(rawValue: 1 << 0)
    static let banned        = Self.init(rawValue: 1 << 1)
    static let featured      = Self.init(rawValue: 1 << 2)
}

// Declare Data Transferrable Objects
// https://docs.vapor.codes/fluent/model/#data-transfer-object
extension User {
    /// DTO to be sent to the client that hides information like the password hash
    struct Public: Content {
        var id: UUID?
        var username: String
        var isAdmin: Bool?
        var createdAt: Date?
        var updatedAt: Date?
        
        init(_ user: User) {
            self.id = user.id
            self.username = user.username
            self.isAdmin = user.userRoles.contains(.admin)
            self.createdAt = user.createdAt
            self.updatedAt = user.updatedAt
        }
    }
}
