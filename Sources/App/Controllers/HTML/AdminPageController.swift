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
        let admin = protected.grouped("admin")
        admin.get("allCards", use: allCards)
    }

    func index(req: Request) async throws -> View {
        let admin = try req.auth.require(Admin.self)
        let publicUser = User.Public.init(admin.user)
//        var headers = HTTPHeaders()
//        headers.contentDisposition = .init(.attachment, filename: "test.json")
        
        let context = CreateContext(
            title: "Admin Panel",
            user: publicUser
        )
        return try await req.view.render("admin", context)
    }
    
    func allCards(req: Request) async throws -> Response {
        var headers = HTTPHeaders()
        // Set this header so that browsers will download the file instead of display in-browser
        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
        headers.contentDisposition = .init(.attachment, filename: "deck.json")
        
        let ttsDeck = try await allCardsJSON(for: req)
        return try await ttsDeck.encodeResponse(status: .ok, headers: headers, for: req)
    }
}

struct AdminContext: Encodable {
    var title: String
    var user: User.Public?
}
