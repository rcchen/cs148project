//
//  ViewController.swift
//  cs148project
//
//  Created by Roger Chen on 8/9/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var scoreLabel: UILabel!
    
    var hitMutex: Bool = false // poor man's mutex
    var hitTargets: Set<Int> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the delegate
        sceneView.delegate = self

        // container for all of the geometry
        let scene = SCNScene()
        
        // set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self

        // default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // add debug visualizations
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]

        // add debug stats
        sceneView.showsStatistics = true

        // temporarily add the hoop to the scene
        self.addHoopToScene()
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

    // MARK: - SCNPhysicsContactDelegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // figure out which one of the contact nodes is the hoop
        var hoopNode: Hoop? = nil
        if (contact.nodeA is Hoop) {
            hoopNode = contact.nodeA as? Hoop
        } else if (contact.nodeB is Hoop) {
            hoopNode = contact.nodeB as? Hoop
        }
        
        // assuming that we actually have a hoop, run through the distance calculations
        if (hoopNode != nil) {
            let nodeAPosition = contact.nodeA.presentation.position
            let nodeBPosition = contact.nodeB.presentation.position
            
            let distance = nodeAPosition.distance(vector: nodeBPosition)
            
            // we have a bit of a magic number here
            if (distance < 0.18) {
                let greenMaterial = SCNMaterial()
                greenMaterial.diffuse.contents = UIColor.green
                hoopNode?.geometry?.materials = [ greenMaterial ]
                if (hitMutex == false) {
                    let when = DispatchTime.now() + 0.5
                    hitMutex = true
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.hitTargets.insert(hoopNode!.id)
                        self.scoreLabel.text = String(self.hitTargets.count)
                        self.hitMutex = false
                        hoopNode?.removeFromParentNode()
                        self.addHoopToScene()
                    }
                }
            }
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    var panStart: CGPoint? = nil
    var panVelocity: CGPoint? = nil
    
    /**
     * Figures out how to throw the ball based on how the pan action has started and ended.
     */
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            panStart = sender.location(in: sceneView)
        }

        if (sender.state == .ended) {
            panVelocity = sender.velocity(in: sceneView)
            
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

    /**
     * Add a hoop somewhere within the scene, ideally not too far away from the origin.
     */
    func addHoopToScene() {
        let posX = floatBetween(-0.5, and: 0.5)
        let posY = floatBetween(-0.5, and: 0.5)

        // set things to the node
        let hoop = Hoop()
        hoop.position = SCNVector3Make(posX, posY, -2)

        // add it to the scene
        sceneView.scene.rootNode.addChildNode(hoop)
    }

    /**
     * Generates a random float between upper and lower bound (inclusive)
     * Taken from https://github.com/farice/ARShooter/blob/master/ARViewer/ViewController.swift#L202
     */
    func floatBetween(_ first: Float,  and second: Float) -> Float {
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    /**
     * Throw a ball at the defined velocity. Start position is always from the current point of view.
     */
    func throwBall(velocity: SCNVector3) {
        // get necessary data from the scene camera
        let camera = sceneView.session.currentFrame?.camera
        let transformMatrix = camera?.transform

        // create start position
        let pov = sceneView.pointOfView?.position
        
        // cmompute the overall direction to take
        let adjustedVelocity = float4(-4 * velocity.x, velocity.y, -4, 1)
        let direction = transformMatrix! * adjustedVelocity

        // transform into an SCNVector
        let mSCNDirection = SCNVector3Make(direction.x, direction.y, direction.z)

        // create the ball and set its characteristics
        let ball = Ball()
        ball.position = pov!
        ball.physicsBody?.applyForce(mSCNDirection, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ball)
    }
}


