//
//  Ball.swift
//  cs148project
//
//  Created by Roger Chen on 8/14/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import SceneKit

class Ball: SCNNode {
    static let radius = CGFloat(0.1)
    static let mass = CGFloat(1.0)
    
    override init() {
        super.init()
        
        // establish geometry
        let sphere = SCNSphere(radius: Ball.radius)
        self.geometry = sphere

        // establish physics body
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        physicsBody.mass = Ball.mass
        
        // add collision categories
        physicsBody.categoryBitMask = CollisionCategory.Ball.rawValue
        physicsBody.collisionBitMask = CollisionCategory.Basket.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.Basket.rawValue
        
        // add the physics body to the node
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
