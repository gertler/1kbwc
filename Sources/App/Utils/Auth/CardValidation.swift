//
//  CardValidation.swift
//  
//
//  Created by Harrison Gertler on 2/28/23.
//

import Vapor

// Used to create a new Card
extension Card {
    struct Create: Content {
        var title: String
    }
}

// Used to validate the creation of a new Card
extension Card.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(1...100))
    }
}
