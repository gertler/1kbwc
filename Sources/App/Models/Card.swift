//
//  Card.swift
//  
//
//  Created by Harrison Gertler on 1/18/23.
//

import Fluent
import Vapor

final class Card: Model, Content {
    static let schema = "cards"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String
    
    // When this Card was created.
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
