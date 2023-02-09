//
//  RedirectService.swift
//  
//
//  Created by Harrison Gertler on 2/8/23.
//

import Vapor

struct RedirectService {
    /**
     * Extracts a `Content`'s fields and creates an HTTP query `String` from them
     *
     * This builds an HTTP query `String` to pass to redirect routes using a given `Content` object
     * ```
     * let content = User(name: "Bob", age: 32)
     * let extracted = try extractParams(user)
     * print(extracted) // "?name=Bob&age=32"
     * ```
     *
     * - parameter params:  A `Content` object to be converted to a query
     * - returns:           A query String beginning with "?"
     */
    func extractParams<T: Content>(params content: T) throws -> String {
        let data = try URLEncodedFormEncoder().encode(content)
        return "?\(data)"
    }
}

extension Request {
    /// A service for helping to handle route redirects
    var redirectService: RedirectService {
        .init()
    }
}
