//
//  IndexPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct IndexPageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        let context = IndexContext(
            title: "Welcome",
            user: user
        )
        return try await req.view.render("index", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct IndexContext: Encodable {
    var title: String
    var user: User?
}