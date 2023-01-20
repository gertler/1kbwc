//
//  AWSService.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Vapor
import SotoS3

struct AWSConfig {
    private let awsClient: AWSClient? = {
        // Access Key ID from text file
        let accessKeyIDFilename = Environment.get("AWS_ACCESS_KEY_FILE") ?? ""
        let accessKeyIDFile = URL.init(fileURLWithPath: accessKeyIDFilename)
        guard let accessKeyID = try? String.init(contentsOf: accessKeyIDFile) else { return nil }
        
        // Secret Access Key from text file
        let secretAccessKeyFilename = Environment.get("AWS_SECRET_ACCESS_KEY_FILE") ?? ""
        let secretAccessKeyFile = URL.init(fileURLWithPath: secretAccessKeyFilename)
        guard let secretAccessKey = try? String.init(contentsOf: secretAccessKeyFile) else { return nil }
        
        let client = AWSClient(credentialProvider: .static(accessKeyId: accessKeyID, secretAccessKey: secretAccessKey),
                               httpClientProvider: .createNew)
        return client
    }()
    
    private var s3: S3?
    
    func testUpload() async throws {
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            throw Abort(.imATeapot)
        }
        let lorumText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed..."
        let putObjectRequest = S3.PutObjectRequest(
            body: .string(lorumText),
            bucket: bucketName,
            key: "lorum.txt"
        )
        
        _ = try await s3?.putObject(putObjectRequest)
    }
    
    init() {
        if let client = awsClient {
            s3 = S3(client: client, region: .useast1)
        }
    }
}

extension Request {
    var awsConfig: AWSConfig {
        .init()
    }
}
