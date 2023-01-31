//
//  CleanupUserTokensJob.swift
//  
//
//  Created by Harrison Gertler on 1/31/23.
//

import Vapor
import Queues

struct CleanupUserTokensJob: AsyncScheduledJob {
    func run(context: Queues.QueueContext) async throws {
        let db = context.application.db
        let tokens = try await UserToken.query(on: db).all()
        for token in tokens {
            // If token is invalid, delete it from the db
            if !token.isValid {
                try await token.delete(on: db)
            }
        }
    }
}
