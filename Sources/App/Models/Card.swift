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
    
    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, title: String, s3Filepath: String? = nil, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.s3Filepath = s3Filepath
        self.$user.id = userID
    }
}

// Declare Data Transferrable Objects
// https://docs.vapor.codes/fluent/model/#data-transfer-object
extension Card {
    /// DTO to be sent to the client
    struct Public: Content {
        var id: UUID?
        var title: String
        var createdAt: Date?
        var user: User.Public
        
        init(_ card: Card) throws {
            self.id = card.id
            self.title = card.title
            self.createdAt = card.createdAt
            self.user = User.Public.init(card.user)
        }
    }
}
