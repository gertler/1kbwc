//
//  AdminPageController.swift
//  
//
//  Created by Harrison Gertler on 2/22/23.
//

import Fluent
import Vapor

struct AdminPageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped([
            User.redirectMiddleware(path: "/"),
            Admin.AdminAuthenticator(),
            Admin.redirectMiddleware(path: "/")
        ])
        protected.get("admin", use: index)
    }

    func index(req: Request) async throws -> View {
        let admin = try req.auth.require(Admin.self)
        let publicUser = User.Public.init(admin.user)
        
        let context = CreateContext(
            title: "Admin Panel",
            user: publicUser
        )
        return try await req.view.render("admin", context)
    }
}

struct AdminContext: Encodable {
    var title: String
    var user: User.Public?
}
