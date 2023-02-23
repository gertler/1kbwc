//
//  CreateAdmin.swift
//  
//
//  Created by Harrison Gertler on 2/23/23.
//

import Vapor
import Fluent

extension Admin {
    struct CreateAdmin: AsyncMigration {        
        func prepare(on database: Database) async throws {
            guard let adminUsername = Environment.get(.admin_user),
                  let adminPassword = Environment.get(.admin_pass) else {
                throw Abort(.expectationFailed, reason: "Admin username and/or password missing from environment")
            }
            
            // NOTE: Bcrypt is used to encrypt password in UserController.swift:create(req: Request)
            // This is defined in configure.swift via `app.passwords.use(.bcrypt)`
            let hash = try Bcrypt.hash(adminPassword)
            let adminUser = User(username: adminUsername, passwordHash: hash)
            adminUser.userRoles = [.admin]
            try await adminUser.save(on: database)
        }

        func revert(on database: Database) async throws {
            guard let adminUsername = Environment.get(.admin_user) else {
                throw Abort(.expectationFailed, reason: "Admin username missing from Environment")
            }
            guard let adminUser = try await User.query(on: database).filter(\.$username == adminUsername).first() else {
                throw Abort(.expectationFailed, reason: "Admin User doesn't exist in database")
            }
            
            try await adminUser.delete(on: database)
        }
    }
}
