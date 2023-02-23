//
//  CreatePageController.swift
//  
//
//  Created by Harrison Gertler on 1/31/23.
//

import Fluent
import Vapor

struct CreatePageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped([
            User.redirectMiddleware(path: "/")
        ])
        protected.get("create", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = try req.auth.require(User.self)
        let publicUser = User.Public.init(user)
        
        let context = CreateContext(
            title: "Create a Card",
            user: publicUser
        )
        return try await req.view.render("create", context)
    }
}

struct CreateContext: Encodable {
    var title: String
    var user: User.Public?
}
