//
//  AdminPageController+JSON.swift
//  
//
//  Created by Harrison Gertler on 2/27/23.
//

import Vapor

extension AdminPageController {
    private var idToRealIdValue: Int { 100 }
    private var indexStart: Int { 24501 }
    
    /**
     * This builds a `TTSDeck` from all the cards in the server's database
     *
     * Using this function CAN potentially lead to the app running low or out of memory, due to having to create a large `Codable` object
     * that has no specific cap on how big it can be.
     *
     * - parameter req: The `Request` for which this JSON is in response to; used for logging and db access
     * - returns:       A `TTSDeck` that encodes data for all cards currently in the database
     */
    func allCardsJSON(for req: Request) async throws -> TTSDeck {
        let cards = try await Card.query(on: req.db).all()
        return try await buildJSON(cards: cards, deckName: "AllCardsDeck")
    }
    
    /**
     * TODO
     */
    private func buildJSON(cards: [Card], deckName: String) async throws -> TTSDeck {
        let deckIDs = (0..<cards.count).map { ($0 + indexStart) * idToRealIdValue }
        async let customDeckCards = try zip(cards, deckIDs).map { card, id in
            try generateCard(id: id, card: card)
        }
        async let containedObjects = zip(cards, deckIDs).map { card, id in
            let ttsCard = try generateCard(id: id, card: card)
            
            return ContainedObject(name: "Card",
                                   transform: Transform(),
                                   nickname: card.title,
                                   description: "Description of \(card.title)",
                                   cardID: id,
                                   customDeck: CustomDeck(cards: [ttsCard]))
        }
        
        let deckState = try await ObjectState(name: deckName,
                                              transform: Transform(),
                                              deckIDs: deckIDs,
                                              customDeck: CustomDeck(cards: customDeckCards),
                                              containedObjects: containedObjects)
        let ttsDeck = TTSDeck.init(objectStates: [deckState])
        return ttsDeck
    }
    
    private func generateCard(id: Int, card: Card) throws -> TTSCard {
        let realID = id / idToRealIdValue
        let server = Environment.get(.server_name)
        let uri = URI.init(scheme: .https, host: server, path: "")
        return TTSCard(cardID: String.init(realID),
                       faceURL: "\(uri)/cards/\(try card.requireID())",
                       backURL: "\(uri)/static/img/CardBack.png")
    }
}
