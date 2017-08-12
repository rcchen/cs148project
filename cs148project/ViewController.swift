//
//  ViewController.swift
//  cs148project
//
//  Created by Roger Chen on 8/9/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the delegate
        sceneView.delegate = self

        // container for all of the geometry
        let scene = SCNScene()
        
        // 3d cube
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        
        // node that wraps the cube
        let node = SCNNode(geometry: box)
        node.position = SCNVector3Make(0, 0, -0.5)
        
        // add to the root node
        scene.rootNode.addChildNode(node)
        
        // set the scene to the view
        self.sceneView.scene = scene
        
        // default lighting
        self.sceneView.autoenablesDefaultLighting = true
        
        // add debug visualizations
        self.sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // plane tracking
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let plane = Plane(anchor: planeAnchor)
        node.addChildNode(plane)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }

        let plane = Plane(anchor: planeAnchor)
        node.addChildNode(plane)
    }
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    // MARK: - HitTest (TODO FIGURE OUT THE RIGHT DELEGATE TO CALL THIS)

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self.sceneView)
        let result = self.sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if (result.count == 0) { return }
        
        let hitResult = result.first
//        self.insertGeometry(hitResult: hitResult!)
        self.throwBall(hitResult: hitResult!)
    }

//    @IBAction func handleSwipe(_ sender: UISwipeGestureRecognizer) {
//        let swipeStartPoint = sender.location(in: self.sceneView)
//        let swipeDirection = sender.direction
//
//        print(swipeDirection)
//
//        if (swipeDirection == .up) {
//
//        }
//    }

    // MARK: - Utility methods
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))

        let grassMaterial = SCNMaterial()
        grassMaterial.diffuse.contents = #imageLiteral(resourceName: "grass")
        grassMaterial.isDoubleSided = true
        plane.materials = [ grassMaterial ]

        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

        return planeNode
    }

    func insertGeometry(hitResult: ARHitTestResult) {
        let dimension = CGFloat(0.1)
        
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        let node = SCNNode(geometry: cube)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0

        let insertionYOffset = Float(0.0)
        node.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + insertionYOffset,
            hitResult.worldTransform.columns.3.z
        )
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func throwBall(hitResult: ARHitTestResult) {
        let radius = CGFloat(0.1)
        
        let sphere = SCNSphere(radius: radius)
        let node = SCNNode(geometry: sphere)

        let position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        let direction = SCNVector3Make(0, 3, -2)
        
        node.position = position
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.applyForce(direction, asImpulse: true)
        node.physicsBody?.mass = 2.0
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
}
