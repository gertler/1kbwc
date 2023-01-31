//
//  CreateUserToken.swift
//  
//
//  Created by Harrison Gertler on 1/30/23.
//

import Fluent

extension UserToken {
    struct CreateUserToken: AsyncMigration {
        var name: String { "CreateUserToken" }
        
        func prepare(on database: Database) async throws {
            try await database.schema(UserToken.schema)
                .id()
                .field("value", .string, .required)
                .field("issued_at", .datetime)
                .field("user_id", .uuid, .required, .references(User.schema, .id))
                .unique(on: "value")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(UserToken.schema).delete()
        }
    }
}
