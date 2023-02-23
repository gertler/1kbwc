//
//  CreateCards.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent

extension Card {
    struct CreateCards: AsyncMigration {        
        func prepare(on database: Database) async throws {
            try await database.schema(Card.schema)
                .id()
                .field("title", .string, .required)
                .field("s3_filepath", .string)
                .field("created_at", .datetime)
                .field("user_id", .uuid, .required, .references(User.schema, .id))
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Card.schema).delete()
        }
    }
}
