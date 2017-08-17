//
//  FixedPlaneViewController.swift
//  cs148project
//
//  Created by Roger Chen on 8/16/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class FixedPlaneViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var scoredBalls: Set<Int> = Set()

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the delegate
        sceneView.delegate = self
        
        // container for all of the geometry
        let scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        
        // set the scene to the view
        sceneView.scene = scene
        
        // default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // add debug visualizations
        sceneView.debugOptions = [
            ARSCNDebugOptions.showFeaturePoints
        ]

        // add debug stats
        sceneView.showsStatistics = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // plane tracking
        configuration.planeDetection = .horizontal
        
        // run the session
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // pause the session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelgate
    
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

    // MARK: - Scene setup logic

    var isPlacingTrashCan = false
    var placedTrashCan = false
    var trashCanBottomNode: CanBottom!
    var trashCanNode: Can? = nil
    
    @IBAction func resetScene(_ sender: UIButton) {
        placedTrashCan = false
        isPlacingTrashCan = true
        trashCanBottomNode.removeFromParentNode()
        trashCanNode?.removeFromParentNode()
        trashCanBottomNode = nil
        trashCanNode = nil
    }
    
    @IBAction func onTapScreen(_ sender: UITapGestureRecognizer) {
        // if there is no trash can
        if (trashCanNode != nil) {
            return
        }

        let tapPoint = sender.location(in: self.sceneView)
        let result = self.sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if (result.count == 0) { return }
        
        let hitResult = result.first
        self.addTrashCan(hitResult: hitResult!)

    }

    func addTrashCan(hitResult: ARHitTestResult) {
        let can = Can()
        can.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + Float(Can.height / 2) + Float(Can.bottomHeight),
            hitResult.worldTransform.columns.3.z
        )
        self.sceneView.scene.rootNode.addChildNode(can)
        trashCanNode = can

        // bottom of trash can
        let canBottom = CanBottom()
        canBottom.position = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        self.sceneView.scene.rootNode.addChildNode(canBottom)
        trashCanBottomNode = canBottom
    }

    @IBAction func endGame(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIPanGestureRecognizer

    var panStart: CGPoint? = nil
    var panVelocity: CGPoint? = nil

    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .began) {
            panStart = sender.location(in: sceneView)
        }
        
        if (sender.state == .ended) {
            panVelocity = sender.velocity(in: sceneView)
            
            let normalizedPanVelocity = panVelocity?.normalized()
            let velocity = SCNVector3Make(
                Float(-normalizedPanVelocity!.y) + Float(panStart!.x),
                Float(normalizedPanVelocity!.x) + Float(panStart!.y),
                1
            )
            
            self.throwBall(velocity: velocity)
        }
    }

    // MARK: - SCNPhysicsContactDelegate
    
    var activeBall: Ball? = nil

    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        if (activeBall == nil) { return }
        
        let yPos = activeBall!.presentation.position.y
        if (yPos < Float(-10)) {
            activeBall?.removeFromParentNode()
            activeBall = nil
            return
        }
        
        let ballId = self.activeBall!.id
        let physicsBody = activeBall!.physicsBody!
        if (self.almostResting(velocity: physicsBody.velocity)) {
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.scoredBalls.insert(ballId)
                self.scoreLabel.text = String(self.scoredBalls.count)
                self.activeBall = nil
            }
        }
    }
    
    // MARK: - Utility methods

    /**
     * Because things don't perfectly rest.
     */
    func almostResting(velocity: SCNVector3) -> Bool {
        return velocity.length() < 0.1
    }

    /**
     * Throw a ball at the defined velocity. Start position is always from the current point of view.
     */
    func throwBall(velocity: SCNVector3) {
        if (activeBall != nil) {
            return
        }

        // get necessary data from the scene camera
        let camera = sceneView.session.currentFrame?.camera
        let transformMatrix = camera?.transform
        
        // create start position
        let pov = sceneView.pointOfView?.position
        
        // adjust the pov upwards
        let startPosition = SCNVector3Make(
            pov!.x,
            pov!.y + 0.01,
            pov!.z
        )

        // cmompute the overall direction to take
        let adjustedVelocity = float4(-4 * velocity.x, velocity.y, -4, 1)
        let direction = transformMatrix! * adjustedVelocity
        
        // transform into an SCNVector
        let mSCNDirection = SCNVector3Make(direction.x, direction.y, direction.z)
        
        // create the ball and set its characteristics
        let ball = Ball(radius: CGFloat(0.08))
        ball.position = startPosition
        ball.physicsBody?.applyForce(mSCNDirection, asImpulse: true)
        
        activeBall = ball

        sceneView.scene.rootNode.addChildNode(ball)
    }

    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var bestLabel: UILabel!
}
