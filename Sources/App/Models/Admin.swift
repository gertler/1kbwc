//
//  Admin.swift
//  
//
//  Created by Harrison Gertler on 2/22/23.
//

import Vapor

final class Admin: Content {
    let user: User

    init(user: User) {
        self.user = user
    }
}
