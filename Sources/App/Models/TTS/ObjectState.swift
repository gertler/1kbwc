//
//  ObjectState.swift
//  
//
//  Created by Harrison Gertler on 2/23/23.
//

import Vapor

typealias ContainedObject = ObjectState

struct ObjectState: Content {
    var guid: String?
    var name: String
    var transform: Transform
    var nickname: String?
    var description: String?
    var gmNotes: String?
    var altLookAngle: [String: Float]?
    var colorDiffuse: [String: Float]?
    var tags: [String]?
    var layoutGroupSortIndex: Int?
    var value: Float?
    var locked: Bool?
    var grid: Bool?
    var snap: Bool?
    var ignoreFoW: Bool?
    var measureMovement: Bool?
    var dragSelectable: Bool?
    var autoraise: Bool?
    var sticky: Bool?
    var tooltip: Bool?
    var gridProjection: Bool?
    var cardID: Int?
    var hideWhenFaceDown: Bool?
    var hands: Bool?
    var sidewaysCard: Bool?
    var deckIDs: [Int]?
    var customDeck: CustomDeck?
    var luaScript: String?
    var luaScriptState: String?
    var xmlUI: String?
    var containedObjects: [ContainedObject]?
    
    private enum CodingKeys: String, CodingKey {
        case guid = "GUID"
        case name = "Name"
        case transform = "Transform"
        case nickname = "Nickname"
        case description = "Description"
        case gmNotes = "GMNotes"
        case altLookAngle = "AltLookAngle"
        case colorDiffuse = "ColorDiffuse"
        case tags = "Tags"
        case layoutGroupSortIndex = "LayoutGroupSortIndex"
        case value = "Value"
        case locked = "Locked"
        case grid = "Grid"
        case snap = "Snap"
        case ignoreFoW = "IgnoreFoW"
        case measureMovement = "MeasureMovement"
        case dragSelectable = "DragSelectable"
        case autoraise = "Autoraise"
        case sticky = "Sticky"
        case tooltip = "Tooltip"
        case gridProjection = "GridProjection"
        case cardID = "CardID"
        case hideWhenFaceDown = "HideWhenFaceDown"
        case hands = "Hands"
        case sidewaysCard = "SidewaysCard"
        case deckIDs = "DeckIDs"
        case customDeck = "CustomDeck"
        case luaScript = "LuaScript"
        case luaScriptState = "LuaScriptState"
        case xmlUI = "XmlUI"
        case containedObjects = "ContainedObjects"
    }
}
