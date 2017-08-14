//
//  Hoop.swift
//  cs148project
//
//  Created by Roger Chen on 8/14/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import SceneKit

class Hoop: SCNNode {
    static let pipeRadius = CGFloat(0.05)
    static let ringRadius = CGFloat(0.3)

    let id: Int
    
    override init() {
        self.id = Int(arc4random())
        
        super.init()
        
        // establish geometry
        let hoop = SCNTorus(ringRadius: Hoop.ringRadius, pipeRadius: Hoop.pipeRadius)
        self.geometry = hoop
        
        // establish physics body
        let shape = SCNPhysicsShape(geometry: hoop, options: [
            SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron
        ])
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        physicsBody.isAffectedByGravity = false
        
        // add collision categories
        physicsBody.categoryBitMask = CollisionCategory.Basket.rawValue
        physicsBody.collisionBitMask = CollisionCategory.Ball.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.Ball.rawValue
        
        // add the physics body to the node
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//let ringRadius = CGFloat(0.3)
//let pipeRadius = CGFloat(0.05)
//// we simplify this by only dealing with a torus, and then dealing with hits later
//let torus = SCNTorus(ringRadius: ringRadius, pipeRadius: pipeRadius)
//let node = SCNNode(geometry: torus)
//
//// give it a position somewhere, handle physics
//let physicsShape = SCNPhysicsShape(geometry: torus, options: [
//    SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron
//    ])
//let physicsBody = SCNPhysicsBody(type: .kinematic, shape: physicsShape)
//physicsBody.isAffectedByGravity = false
//physicsBody.categoryBitMask = CollisionCategory.Basket.rawValue
//physicsBody.collisionBitMask = CollisionCategory.Ball.rawValue

