//
//  Can.swift
//  cs148project
//
//  Created by Roger Chen on 8/17/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import SceneKit

class Can: SCNNode {
    static let innerRadius = CGFloat(0.2)
    static let outerRadius = Can.innerRadius + 0.01
    static let height = CGFloat(0.4)
    static let bottomHeight = CGFloat(0.01)
    
    let id: Int
    
    override init() {
        self.id = Int(arc4random())

        super.init()
        
        // establish geometry
        let can = SCNTube(innerRadius: Can.innerRadius, outerRadius: Can.outerRadius, height: Can.height)

        // establish material
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "wire")
        can.materials = [ material ]
        
        // set geometry
        self.geometry = can
        
        // establish physics body
        let shape = SCNPhysicsShape(geometry: can, options: [
            SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron
        ])
        let physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        physicsBody.isAffectedByGravity = false
        physicsBody.rollingFriction = 0.8

        // add collision categories
        physicsBody.categoryBitMask = CollisionCategory.Can.rawValue
        physicsBody.collisionBitMask = CollisionCategory.Ball.rawValue
        physicsBody.contactTestBitMask = CollisionCategory.Ball.rawValue

        // add the physics body
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
