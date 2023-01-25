//
//  AWSService.swift
//  
//
//  Created by Harrison Gertler on 1/19/23.
//

import Vapor
import SotoS3

struct AWSService {
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
    
    private let bucketName: String? = Environment.get("S3_BUCKET_NAME")
    
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
    
    /**
     * Attempts to upload a given card with data and title to the configured S3 bucket
     *
     * - parameter cardDataBuffer:  The card data ByteBuffer object to upload
     * - parameter cardTitle:       The card's title given by the client
     * - parameter logger:          An optional logger to use
     * - returns:                   The filepath String in the S3 bucket where the file is stored
     */
    func uploadPNG(_ cardDataBuffer: ByteBuffer, cardTitle title: String, logger: Logger? = nil) async throws -> String {
        let key = formatDateKey(title)
        let size = ByteCountFormatter().string(fromByteCount: Int64(cardDataBuffer.readableBytes))
        logger?.debug("Begin to upload file \(key); size: \(size)")
        
        let putObjectRequest = S3.PutObjectRequest(
            body: .byteBuffer(cardDataBuffer),
            bucket: bucketName!,
            key: key
        )
        let output = try await s3?.putObject(putObjectRequest)
        logger?.debug("Successfully uploaded file! ETag: \(output?.eTag ?? "")")
        
        return key
    }
    
    private func formatDateKey(_ key: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let path = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "HH_mm_ss"
        let suffix = dateFormatter.string(from: Date())
        return "\(path)/\(key)_\(suffix).png"
    }
    
    init() {
        if let client = awsClient {
            s3 = S3(client: client, region: .useast1)
        }
    }
}

extension Request {
    var awsService: AWSService {
        .init()
    }
}
