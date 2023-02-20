//
//  Environment+Keys.swift
//  
//
//  Created by Harrison Gertler on 2/17/23.
//

import Vapor

extension Environment {
    /// Custom keys for environment variables
    ///
    /// Associated values are booleans for whether the variable is represented as a text file path.
    enum Key: String {
        case db_user = "DATABASE_USERNAME_FILE"
        case db_pass = "DATABASE_PASSWORD_FILE"
        case db_name = "DATABASE_NAME_FILE"
        case db_host = "DATABASE_HOST"
        case db_port = "DATABASE_PORT"
        
        case redis_host = "REDIS_HOST"
        case redis_port = "REDIS_PORT"
        
        case aws_key = "AWS_ACCESS_KEY_FILE"
        case aws_secret_key = "AWS_SECRET_ACCESS_KEY_FILE"
        case s3_bucket = "S3_BUCKET_NAME"
        case s3_region = "S3_REGION"
        
        func isFile() -> Bool {
            switch self {
            case .db_user, .db_pass, .db_name, .aws_key, .aws_secret_key:
                return true
            default:
                return false
            }
        }
    }
    
    static func get(_ key: Key) -> String? {
        guard key.isFile() else {
            return get(key.rawValue)
        }
        return try? unwrapSecretFile(key)
    }
}