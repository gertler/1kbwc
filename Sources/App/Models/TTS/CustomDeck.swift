//
//  CustomDeck.swift
//  
//
//  Created by Harrison Gertler on 2/24/23.
//

import Vapor

struct CustomDeck: Content {
    var cards: [TTSCard]
    
    private struct CardIDKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    
    init(cards: [TTSCard]) {
        self.cards = cards
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CardIDKey.self)
        var cards: [TTSCard] = []
        for key in container.allKeys {
            guard let cardIDKey = CardIDKey(stringValue: key.stringValue) else {
                throw DecodingError.keyNotFound(key, .init(codingPath: container.codingPath, debugDescription: "No key found for \"cardID\""))
            }
            let card = try container.decode(TTSCard.self, forKey: cardIDKey)
            cards.append(card)
        }
        self.cards = cards
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CardIDKey.self)
        
        for card in cards {
            if let codingKey = CardIDKey(stringValue: card.cardID) {
                try container.encode(card, forKey: codingKey)
            }
        }
    }
}

struct TTSCard: Content {
    var cardID: String
    var faceURL: String
    var backURL: String
    var numWidth: Int
    var numHeight: Int
    var backIsHidden: Bool
    var uniqueBack: Bool?
    var type: Int?
    
    private enum CodingKeys: String, CodingKey {
        case faceURL = "FaceURL"
        case backURL = "BackURL"
        case numWidth = "NumWidth"
        case numHeight = "NumHeight"
        case backIsHidden = "BackIsHidden"
        case uniqueBack = "UniqueBack"
        case type = "Type"
    }
    
    init(cardID: String,
         faceURL: String,
         backURL: String,
         numWidth: Int = 1,
         numHeight: Int = 1,
         backIsHidden: Bool = true,
         uniqueBack: Bool? = nil,
         type: Int? = nil) {
        self.cardID = cardID
        self.faceURL = faceURL
        self.backURL = backURL
        self.numWidth = numWidth
        self.numHeight = numHeight
        self.backIsHidden = backIsHidden
        self.uniqueBack = uniqueBack
        self.type = type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let key = container.codingPath.first?.stringValue else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: container.codingPath, debugDescription: "No value found for key, \"cardID\""))
        }
        self.cardID = key
        
        self.faceURL = try container.decode(String.self, forKey: .faceURL)
        self.backURL = try container.decode(String.self, forKey: .backURL)
        self.numWidth = try container.decode(Int.self, forKey: .numWidth)
        self.numHeight = try container.decode(Int.self, forKey: .numHeight)
        self.backIsHidden = try container.decode(Bool.self, forKey: .backIsHidden)
        self.uniqueBack = try container.decode(Bool.self, forKey: .uniqueBack)
        self.type = try container.decode(Int.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.faceURL, forKey: .faceURL)
        try container.encode(self.backURL, forKey: .backURL)
        try container.encode(self.numWidth, forKey: .numWidth)
        try container.encode(self.numHeight, forKey: .numHeight)
        try container.encode(self.backIsHidden, forKey: .backIsHidden)
        try container.encodeIfPresent(self.uniqueBack, forKey: .uniqueBack)
        try container.encodeIfPresent(self.type, forKey: .type)
    }
}
