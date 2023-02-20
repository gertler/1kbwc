//
//  File.swift
//  
//
//  Created by Harrison Gertler on 1/30/23.
//

import Vapor

extension Environment {
    
    private static func unwrapSecretFile(_ envVar: String) throws -> String {
        let filename = self.get(envVar) ?? ""
        let file = URL.init(fileURLWithPath: filename)
        let contents = try String.init(contentsOf: file)
        return contents
    }
    
    /**
     * Unwrap a given environment variable that points to a file path and return the file's contents as a String
     *
     * This function helps when using Docker Secrets, as hidden information such as database credentials is passed in through files.
     * The files should have the path, `/run/secrets/<secret-name>`, and are passed in as environment variables containing this filepath.
     *
     * If the environment variable wasn't set or the app fails to read and parse the contents of the file as a `String`, then an error will be thrown.
     *
     * - parameter envVar:  The environment variable to be read
     * - returns:           A String containing the contents of the file whose path was read from the passed-in environment variable
     */
    static func unwrapSecretFile(_ envVar: Key) throws -> String {
        try unwrapSecretFile(envVar.rawValue)
    }
}
