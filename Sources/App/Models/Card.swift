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
    
    @Field(key: "s3_filepath")
    var s3Filepath: String?
    
    // When this Card was created.
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, title: String, s3Filepath: String? = nil) {
        self.id = id
        self.title = title
        self.s3Filepath = s3Filepath
    }
}

//final class CardPublic: Content {
//    var id: UUID?
//    var title: String
//    var createdAt: Date?
//
//    init(_ card: Card) {
//        self.id = card.id
//        self.title = card.title
//        self.createdAt = card.createdAt
//    }
//}
