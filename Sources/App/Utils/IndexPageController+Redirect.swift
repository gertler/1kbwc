//
//  IndexPageController+Redirect.swift
//  
//
//  Created by Harrison Gertler on 2/10/23.
//

import Vapor

extension IndexPageController {
    struct IndexRedirectQuery: Content {
        var error: Bool?
        var reason: IndexRedirectFailureReason?
        var usernameFill: String?
    }
    
    enum IndexRedirectFailureReason: Codable, CustomStringConvertible {
        var description: String {
            var desc: String
            switch self {
            case .loginFailedWrongPassword:
                desc = "loginFailedWrongPassword"
            case .signupFailedPasswordsMismatch:
                desc = "signupFailedPasswordsMismatch"
            case .loginVapor(let string):
                desc = "loginVapor$\(string)"
            case .signupVapor(let string):
                desc = "signupVapor$\(string)"
            }
            return desc
        }
        
        func encode(to encoder: Encoder) throws {
            var _container = encoder.singleValueContainer()
            try _container.encode(self.description)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            if string.hasPrefix("loginVapor$") {
                let i = string.index(after: string.firstIndex(of: "$")!)
                let a0 = String.init(string.suffix(from: i))
                self = .loginVapor(a0)
            } else if string.hasPrefix("signupVapor$") {
                let i = string.index(after: string.firstIndex(of: "$")!)
                let a0 = String.init(string.suffix(from: i))
                self = .signupVapor(a0)
            } else {
                switch string {
                case IndexRedirectFailureReason.loginFailedWrongPassword.description:
                    self = .loginFailedWrongPassword
                case IndexRedirectFailureReason.signupFailedPasswordsMismatch.description:
                    self = .signupFailedPasswordsMismatch
                default:
                    throw DecodingError.keyNotFound(string.codingKey, DecodingError.Context.init(codingPath: container.codingPath, debugDescription: "Unexpected key found, invalid enum value."))
                }
            }
        }
        
        case loginFailedWrongPassword
        case signupFailedPasswordsMismatch
        case loginVapor(String)
        case signupVapor(String)
    }
}
