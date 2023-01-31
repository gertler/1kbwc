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
            app.sessions.middleware,
            User.sessionAuthenticator(),
            UserToken.authenticator(),
            User.redirectMiddleware(path: "/")
        ])
        
        protected.get("create", use: index)
    }

    func index(req: Request) async throws -> View {
        try await req.view.render("create", ["title": "Create a Card"])
    }
    
    init(_ app: Application) {
        self.app = app
    }
}
