//
//  Plane.swift
//  cs148project
//
//  Created by Roger Chen on 8/9/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import ARKit
import Foundation

class Plane: SCNNode {
    let anchor: ARPlaneAnchor
    let planeGeometry: SCNBox
    
    init(anchor: ARPlaneAnchor) {
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        let planeHeight = CGFloat(0.001)

        self.anchor = anchor
        self.planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0)

        super.init()
        
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "grid")
        self.planeGeometry.materials = [ material ]
        
//        let transparentMaterial = SCNMaterial()
//        transparentMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)

        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3Make(0, Float(-planeHeight / 2), 0)

        let physicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil)
        )
        physicsBody.rollingFriction = 0.8
        planeNode.physicsBody = physicsBody
        
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.anchor = ARPlaneAnchor()
        self.planeGeometry = SCNBox()

        fatalError("init(coder:) has not been implemented")
    }
}
