//
//  AdminAuthentication.swift
//  
//
//  Created by Harrison Gertler on 2/28/23.
//

import Vapor

// Makes it so we can use req.auth.require(Admin.self) to authenticate
// This makes use of the fact that User can be found via req.auth.require(User.self)
extension Admin: Authenticatable { }

// This is a simple Authenticator that checks the User.userRoles contains .admin
extension Admin {
    struct AdminAuthenticator: AsyncRequestAuthenticator {
        func authenticate(request: Vapor.Request) async throws {
            let user = try request.auth.require(User.self)
            guard user.userRoles.contains(.admin) else {
                return
            }
            request.auth.login(Admin(user: user))
        }
    }
}
