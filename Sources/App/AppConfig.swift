//
//  AppConfig.swift
//  
//
//  Created by Harrison Gertler on 1/31/23.
//

import Vapor

struct AppConfig {
    
    static var shared: AppConfig {
        .init()
    }
}
