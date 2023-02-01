//
//  CreatePageController.swift
//  
//
//  Created by Harrison Gertler on 1/31/23.
//

import Fluent
import Vapor

struct CreatePageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped([
            User.redirectMiddleware(path: "/")
        ])
        protected.get("create", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        let context = IndexContext(
            title: "Create a Card",
            user: user
        )
        return try await req.view.render("create", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct CreateContext: Encodable {
    var title: String
    var user: User?
}