//
//  RedirectService.swift
//  
//
//  Created by Harrison Gertler on 2/8/23.
//

import Vapor

struct RedirectService {
    func extractParams<T: Content>(params content: T) throws -> String {
        let data = try URLEncodedFormEncoder().encode(content)
        return "?\(data)"
    }
}

extension Request {
    var redirectService: RedirectService {
        .init()
    }
}
