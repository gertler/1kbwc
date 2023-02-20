//
//  CardController+S3.swift
//  
//
//  Created by Harrison Gertler on 2/20/23.
//

import Vapor
import SotoS3

extension CardController {
    /**
     * Attempts to upload a given card with data and title to the configured S3 bucket
     *
     * - parameter cardDataBuffer:  The card data ByteBuffer object to upload
     * - parameter cardTitle:       The card's title given by the client
     * - parameter logger:          An optional logger to use
     * - returns:                   The filepath String in the S3 bucket where the file is stored
     */
    func uploadPNG(for req: Request, data cardDataBuffer: ByteBuffer, cardTitle title: String) async throws -> String {
        let key = formatDateKey(title)
        let size = ByteCountFormatter().string(fromByteCount: Int64(cardDataBuffer.readableBytes))
        req.logger.debug("Begin to upload file \(key); size: \(size)")
                
        let putObjectRequest = S3.PutObjectRequest(
            body: .byteBuffer(cardDataBuffer),
            bucket: req.aws.s3Bucket,
            key: key
        )
        
        let output = try await req.aws.s3.putObject(putObjectRequest)
        req.logger.debug("Successfully uploaded file! ETag: \(output.eTag ?? "")")
        return key
    }
    
    func downloadPNG(for req: Request, card: Card) async throws -> ByteBuffer {
        guard let cardKey = card.s3Filepath else {
            throw Abort(.expectationFailed, reason: "Card has no file data saved")
        }
        
        req.logger.debug("Requesting file \(cardKey) from S3")
        let getObjectRequest = S3.GetObjectRequest(
            bucket: req.aws.s3Bucket,
            key: cardKey
        )
        let response = try await req.aws.s3.getObject(getObjectRequest)
        guard let bodyBuf = response.body?.asByteBuffer() else {
            throw Abort(.expectationFailed, reason: "Card file is corrupted")
        }
        req.logger.debug("Successfully obtained card from S3!")
        return bodyBuf
    }
    
    /**
     * Formats a given key to prepare for S3 storage
     *
     * The key is prefixed with a date string and suffixed with a time string.
     * - parameter key: The key to format
     * - returns:       The formatted String with datetime timestamp information
     */
    private func formatDateKey(_ key: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        let path = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "HH_mm_ss"
        let suffix = dateFormatter.string(from: Date())
        return "\(path)/\(key)_\(suffix).png"
    }
}

// Parsing public S3 URLs from card names
extension Request.AWS {
    private static var s3URI: String {
        "s3.amazonaws.com"
    }
    
    func objectURIFor(_ cardName: String) throws -> URL {
        let bucket = self.s3Bucket
        guard var url = URL(string: "https://\(bucket).\(Request.AWS.s3URI)") else {
            throw Abort(.internalServerError)
        }
        url.appendPathComponent(cardName)
        return url
    }
}
