//
//  Application+AWSS3.swift
//  
//
//  Created by Harrison Gertler on 2/17/23.
//

import Vapor
import SotoS3

extension Application.AWS {
    struct S3Key: StorageKey {
        typealias Value = S3
    }
    
    struct S3BucketKey: StorageKey {
        typealias Value = String
    }
    
    /// The `S3` object used to send requests such as `PutObjectRequest`
    var s3: S3 {
        get {
            guard let s3 = self.application.storage[S3Key.self] else {
                fatalError("S3 not setup. Use application.aws.s3 = ...")
            }
            return s3
        }
        nonmutating set {
            self.application.storage[S3Key.self] = newValue
        }
    }
    
    /// The S3 Bucket name to use for GET and PUT Requests
    var s3Bucket: String {
        get {
            guard let s3 = self.application.storage[S3BucketKey.self] else {
                fatalError("S3 Bucket not setup. Use application.aws.s3Bucket = ...")
            }
            return s3
        }
        nonmutating set {
            self.application.storage[S3BucketKey.self] = newValue
        }
    }
}

extension Request.AWS {
    var s3: S3 {
        request.application.aws.s3
    }
    var s3Bucket: String {
        request.application.aws.s3Bucket
    }
}
