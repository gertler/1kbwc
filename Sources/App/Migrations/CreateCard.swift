//
//  CreateCard.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent

struct CreateCard: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("cards")
            .id()
            .field("title", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("cards").delete()
    }
}
