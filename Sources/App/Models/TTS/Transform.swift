//
//  Transform.swift
//  
//
//  Created by Harrison Gertler on 2/24/23.
//

import Vapor

struct Transform: Content {
    var posX: Float
    var posY: Float
    var posZ: Float
    var rotX: Float
    var rotY: Float
    var rotZ: Float
    var scaleX: Float
    var scaleY: Float
    var scaleZ: Float
    
    init() {
        self.posX = 0
        self.posY = 1
        self.posZ = 0
        
        self.rotX = 0
        self.rotY = 180
        self.rotZ = 180
        
        self.scaleX = 1
        self.scaleY = 1
        self.scaleZ = 1
    }
    
    init(posX: Float, posY: Float, posZ: Float,
         rotX: Float, rotY: Float, rotZ: Float,
         scaleX: Float, scaleY: Float, scaleZ: Float) {
        self.posX = posX
        self.posY = posY
        self.posZ = posZ
        
        self.rotX = rotX
        self.rotY = rotY
        self.rotZ = rotZ
        
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.scaleZ = scaleZ
    }
}
