//
//  ViewController.swift
//  Universe
//
//  Created by octagon studio on 22/07/18.
//  Copyright © 2018 Cordova. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var draw: UIButton!
    
    let configuration = ARWorldTrackingConfiguration()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.session.run(configuration)
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        startButton()
        resetButton()
    }
    
    
    //START SESSION
    func startButton(){
        let startButton = UIButton(frame: CGRect(x: 20, y: 520, width: 80, height: 80))
        startButton.backgroundColor = .white
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.blue, for: .normal)
        startButton.addTarget(self, action: #selector(onClick), for : .touchUpInside)
        
        self.view.addSubview(startButton)
    }
    
    @objc func onClick(sender: UIButton!){
        self.startSession()
    }
    
    func startSession(){
        
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let moonParent = SCNNode()
        
        //EARTH
        let earth = planet(geometry: SCNSphere(radius: 0.2), diffuse: UIImage(named: "Earth day")!, specular: UIImage(named: "earth specular")!, emission: UIImage(named: "earth emission")!, normal: UIImage(named: "earth normal")!, position: SCNVector3(1.2, 0, 0))

        let earthRotation = Rotation(time: 8)
        
        //VENUS
        let venus = planet(geometry: SCNSphere(radius: 0.1), diffuse: UIImage(named: "Venus Surface")!, specular: nil, emission: UIImage(named: "Venus Atmosphere"), normal: nil, position: SCNVector3(0.7, 0, 0))
        
        let venusRotation = Rotation(time: 8)
        
        //INVISIBLE ORBIT FOR EARTH AND VENUS
        let earthParentRotation = Rotation(time: 14) //Earth
        let venusParentRotation = Rotation(time: 10 ) //Venus
        
        earthParent.position = SCNVector3(0, 0, -1)
        venusParent.position = SCNVector3(0, 0, -1)
        moonParent.position = SCNVector3(1.2, 0, 0)
        
        //MOON
        let moon = planet(geometry: SCNSphere(radius : 0.05), diffuse: UIImage(named: "Moon Diffuse")!, specular: nil, emission: nil, normal: nil, position: SCNVector3(0, 0, -0.3))
        
        let moonRotation = Rotation(time: 3.5)
        
        //SUN
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        sun.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "sun diffuse")
        sun.position = SCNVector3(0, 0, -1)
        
        
        let sunAction = Rotation(time: 8)
        
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        self.sceneView.scene.rootNode.addChildNode(venusParent)
        
        earthParent.addChildNode(earth)
        earthParent.addChildNode(moonParent)
        venusParent.addChildNode(venus)
        moonParent.addChildNode(moon)
        earth.addChildNode(moon)

        
        sun.runAction(sunAction)
        earth.runAction(earthRotation)
        venus.runAction(venusRotation)
        
        earthParent.runAction(earthParentRotation)
        venusParent.runAction(venusParentRotation)
        moonParent.runAction(moonRotation)
        
    }
    
    
    //RESET SESSION
    func resetButton(){
        let resetButton = UIButton(frame: CGRect(x: 280, y: 520, width: 80, height: 80))
        resetButton.backgroundColor = .red
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        
        self.view.addSubview(resetButton)
    }
    
    @objc func onReset(sender: UIButton!){
        self.resetSession()
    }
    
    func resetSession(){
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    
    //PLANET PROPERTIES FUNCTION
    func planet(geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?, emission: UIImage?, normal: UIImage?, position: SCNVector3) -> SCNNode {
        let planet = SCNNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position
        return planet
        
    }
    
    //ROTATION FUNCTION
    func Rotation(time: TimeInterval) -> SCNAction {
        let Rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.convertDegreesToRadians), z:0, duration: time)
        let foreverRotation = SCNAction.repeatForever(Rotation)
        
        return foreverRotation
    }
    
    //RENDER TO DRAW FUNCTION
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let startDrawing = sceneView.pointOfView else {return}
        
        let changingDrawingSequences = startDrawing.transform
        let orientation = SCNVector3(-changingDrawingSequences.m31, -changingDrawingSequences.m32, -changingDrawingSequences.m33)
        let location = SCNVector3(changingDrawingSequences.m41, changingDrawingSequences.m42, changingDrawingSequences.m43)
        let currentDrawingPosition = orientation + location
        
        DispatchQueue.main.async {
            
            if self.draw.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.position = currentDrawingPosition
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
                
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentDrawingPosition
                
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
            }
        }
    }
    
    
    
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

extension Int {
    var convertDegreesToRadians: Double { return Double(self) * .pi/180}
}
