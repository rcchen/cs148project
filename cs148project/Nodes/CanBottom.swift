//
//  CanBottom.swift
//  cs148project
//
//  Created by Roger Chen on 8/17/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import SceneKit

class CanBottom: SCNNode {
    let id: Int
    
    override init() {
        self.id = Int(arc4random())
        
        super.init()
        
        // establish geometry
        let canBottom = SCNCylinder(radius: Can.outerRadius, height: Can.bottomHeight)

        // establish material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.lightGray
        canBottom.materials = [ material ]

        // set geometry
        self.geometry = canBottom
        
        // establish physics body
        let shape = SCNPhysicsShape(geometry: canBottom, options: nil)
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        physicsBody.isAffectedByGravity = false
        physicsBody.rollingFriction = 1.0
        
        // add collision categories
        physicsBody.categoryBitMask = CollisionCategory.Can.rawValue
        physicsBody.collisionBitMask = CollisionCategory.Ball.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.Ball.rawValue
        
        // add the physics body
        self.physicsBody = physicsBody
        
        // try adding a physics field with a bunch of drag
        self.physicsField = SCNPhysicsField.drag()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

