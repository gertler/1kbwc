//
//  Migrations.swift
//  
//
//  Created by Harrison Gertler on 1/30/23.
//

import Fluent

struct Migrations {
    static var shared: [AsyncMigration] {
        [
            User.CreateUser(),
            CreateCard(),
        ]
    }
}
