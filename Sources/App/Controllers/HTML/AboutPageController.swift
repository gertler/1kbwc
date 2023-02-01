//
//  AboutPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct AboutPageController: RouteCollection {
    private let app: Application
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("about", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        let context = IndexContext(
            title: "About",
            user: user
        )
        return try await req.view.render("about", context)
    }
    
    init(_ app: Application) {
        self.app = app
    }
}

struct AboutContext: Encodable {
    var title: String
    var user: User?
}
