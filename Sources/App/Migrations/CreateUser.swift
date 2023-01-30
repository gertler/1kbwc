//
//  CreateUser.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Fluent

extension User {
    struct CreateUser: AsyncMigration {
        var name: String { "CreateUser" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(User.schema)
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .field("created_at", .datetime)
                .field("updated_at", .datetime)
                .unique(on: "username")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(User.schema).delete()
        }
    }
}
