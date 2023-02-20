//
//  Application+AWSClient.swift
//  
//
//  Created by Harrison Gertler on 2/17/23.
//

import Vapor
import SotoCore

extension Application {
    /// The `AWS` object used to access services for AWS
    var aws: AWS {
        .init(application: self)
    }
    
    struct AWS {
        struct ClientKey: StorageKey {
            typealias Value = AWSClient
        }
        
        /// An `AWSClient` object to be configured for handling AWS requests
        var client: AWSClient {
            get {
                guard let client = self.application.storage[ClientKey.self] else {
                    fatalError("AWSClient not setup. Use application.aws.client = ...")
                }
                return client
            }
            nonmutating set {
                self.application.storage.set(ClientKey.self, to: newValue) {
                    try $0.syncShutdown()
                }
            }
        }
        
        let application: Application
    }
}

extension Request {
    /// The `AWS` object used to access services for AWS
    var aws: AWS {
        .init(request: self)
    }
            
    struct AWS {
        /// An `AWSClient` object to be configured for handling AWS requests
        var client: AWSClient {
            return request.application.aws.client
        }

        let request: Request
    }
}
