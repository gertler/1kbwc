//
//  TTSDeck.swift
//  
//
//  Created by Harrison Gertler on 2/23/23.
//

import Foundation

struct TTSDeck: Codable {
    var saveName: String?
    var date: String?
    var versionNumber: String?
    var gameMode: String?
    var gameType: String?
    var gameComplexity: String?
    var tags: [String]?
    var gravity: Float?
    var playArea: Float?
    var table: String?
    var sky: String?
    var note: String?
    var tabStates: [String: String]?
    var luaScript: String?
    var luaScriptState: String?
    var xmlUI: String?
    var objectStates: [ObjectState]
    
    private enum CodingKeys: String, CodingKey {
        case saveName = "SaveName"
        case date = "Date"
        case versionNumber = "VersionNumber"
        case gameMode = "GameMode"
        case gameType = "GameType"
        case gameComplexity = "GameComplexity"
        case tags = "Tags"
        case gravity = "Gravity"
        case playArea = "PlayArea"
        case table = "Table"
        case sky = "Sky"
        case note = "Note"
        case tabStates = "TabStates"
        case luaScript = "LuaScript"
        case luaScriptState = "LuaScriptState"
        case xmlUI = "XmlUI"
        case objectStates = "ObjectStates"
    }
}
