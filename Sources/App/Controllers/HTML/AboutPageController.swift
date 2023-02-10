//
//  AboutPageController.swift
//  
//
//  Created by Harrison Gertler on 2/1/23.
//

import Fluent
import Vapor

struct AboutPageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("about", use: index)
    }

    func index(req: Request) async throws -> View {
        let user = req.auth.get(User.self)
        var publicUser: User.Public?
        if let _user = user {
            publicUser = User.Public.init(_user)
        }
        
        let context = AboutContext(
            title: "About",
            user: publicUser
        )
        return try await req.view.render("about", context)
    }
}

struct AboutContext: Encodable {
    var title: String
    var user: User.Public?
}
