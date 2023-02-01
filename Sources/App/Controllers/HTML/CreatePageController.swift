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
        var publicUser: User.Public?
        if let _user = user {
            publicUser = User.Public.init(_user)
        }
        
        let context = CreateContext(
            title: "Create a Card",
            user: publicUser
        )
        return try await req.view.render("create", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct CreateContext: Encodable {
    var title: String
    var user: User.Public?
}
