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
    
    // When this User was created.
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // When this User was last updated.
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, username: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.passwordHash = passwordHash
    }
    
}

final class UserPublic: Content {
    var id: UUID?
    var username: String
    var password: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(_ user: User) {
        self.id = user.id
        self.username = user.username
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
    }
}
