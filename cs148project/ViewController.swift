//
//  ViewController.swift
//  cs148project
//
//  Created by Roger Chen on 8/9/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import UIKit
import SceneKit
import Accelerate
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the delegate
        sceneView.delegate = self

        // container for all of the geometry
        let scene = SCNScene()
        
        // set the scene to the view
        self.sceneView.scene = scene
        
        // default lighting
        self.sceneView.autoenablesDefaultLighting = true
        
        // add debug visualizations
        self.sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]

        // add debug stats
        self.sceneView.showsStatistics = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    // MARK: - UIGestureRecognizerDelegate

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // action function called when a user taps on the screen
        // used for testing cube placement in the environment

        let tapPoint = sender.location(in: self.sceneView)
        let result = self.sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if (result.count == 0) { return }
        
        let hitResult = result.first
        self.insertGeometry(hitResult: hitResult!)
    }

    var panStart: CGPoint? = nil
    var panVelocity: CGPoint? = nil
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            panStart = sender.location(in: self.sceneView)
        }

        if (sender.state == .ended) {
            panVelocity = sender.velocity(in: self.sceneView)
            
            let normalizedPanVelocity = panVelocity?.normalized()
            let velocity = SCNVector3Make(
                Float(-normalizedPanVelocity!.y),
                Float(normalizedPanVelocity!.x),
                1
            )
            
            self.throwBall(velocity: velocity)
        }
    }

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

    /**
     * Add a hoop somewhere within the scene, ideally not too far away from the origin.
     */
    func addHoopToScene() {
        
    }
    
    /**
     * Throw a ball at the defined velocity. Start position is always from the current point of view.
     */
    func throwBall(velocity: SCNVector3) {
        let radius = CGFloat(0.1)
        
        // initialize the ball that we want to use
        let sphere = SCNSphere(radius: radius)
        let node = SCNNode(geometry: sphere)

        // get necessary data from the scene camera
        let camera = self.sceneView.session.currentFrame?.camera
        let transformMatrix = camera?.transform

        // create start position
        let pov = self.sceneView.pointOfView?.position
        
        // cmompute the overall direction to take
        let adjustedVelocity = float4(-4 * velocity.x, velocity.y, -4, 1)
        let direction = transformMatrix! * adjustedVelocity

        // transform into an SCNVector
        let mSCNDirection = SCNVector3Make(direction.x, direction.y, direction.z)

        node.position = pov!
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.applyForce(mSCNDirection, asImpulse: true)
        node.physicsBody?.mass = 2.0
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
}
