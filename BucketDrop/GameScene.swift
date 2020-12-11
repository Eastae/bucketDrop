//
//  GameScene.swift
//  BucketDrop
//
//  Created by Keith Eastman on 12/10/20.
//  Copyright © 2020 Keith Eastman. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let dropCategory: UInt32 = 1 << 0
    let bucketCategory: UInt32 = 1 << 1
    var scoreCounter: Int = 0
    //Variables and parameters
    
    
    
    //Hello World node (optional)
    private var label : SKLabelNode?
    var contentCreated = false
    
    //HUD elements
    let daScoreBoard = "scoreHud"
    
    //objects
    var playerBucket : SKSpriteNode!
    var background : SKEmitterNode!
    var scoreLabel : SKLabelNode!
    
    func setupHud(){
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = daScoreBoard
        scoreLabel.fontSize = 25

        // 2
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = String(format: "Score: %04u", 0)

        scoreLabel.position = CGPoint(
          x: frame.size.width / 2,
          y: size.height - 50
        )


        addChild(scoreLabel)
    }

    
    override func didMove(to view: SKView) {
        //non-gravity based movement
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //TODO increment scoreboard
        setupHud()
        
        //initialize background rainfall emitter
        background = SKEmitterNode (fileNamed: "Rain.sks")
        background.position = CGPoint(x: size.width/2, y: size.height)
        self.addChild(background)
        

        //our brave hero!
        playerBucket = SKSpriteNode(imageNamed: "bucketE.png")
        playerBucket.position = CGPoint(x: size.width/2, y: 100)
        //Bind Physical properties
        playerBucket.physicsBody = SKPhysicsBody(rectangleOf: playerBucket.size)
        playerBucket.physicsBody?.isDynamic = false
        playerBucket.physicsBody?.categoryBitMask = bucketCategory
        playerBucket.physicsBody?.contactTestBitMask = dropCategory
        addChild(playerBucket)
        
        
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addDroplet),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
//      Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloWorld") as? SKLabelNode
        if let label = self.label {
            label.text = "Bucket Drop"
            label.alpha = 0.0
            label.position = CGPoint(x: size.width/2, y: size.height*0.9)
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        

    }
    
    func random() -> CGFloat {
    //get a potentially huge random varaible
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
    //normalize the random variable
      return random() * (max - min) + min
    }
    
    func addDroplet(){
        let drop = SKSpriteNode(imageNamed: "drop.png")
        
        //the watery menace!
        drop.physicsBody = SKPhysicsBody(circleOfRadius:  drop.size.width/2)
        //bind physical properties
        drop.physicsBody?.isDynamic = true
        drop.physicsBody?.categoryBitMask = dropCategory
        drop.physicsBody?.collisionBitMask = bucketCategory
        drop.physicsBody?.contactTestBitMask = bucketCategory
        drop.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        
        let actualX = random(min: drop.size.width/2, max: size.width - drop.size.width/2)
        
        drop.position = CGPoint(x : actualX, y: size.height - drop.size.height/2)
        
        addChild(drop)
        //how fast the drops move
        let dropTime = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y : -drop.size.width/2), duration: TimeInterval(dropTime))
        let actionMoveDone = SKAction.removeFromParent()
        drop.run(SKAction.sequence([actionMove, actionMoveDone]))
    }

    
    
    @objc func tap(recognizer: UIGestureRecognizer){
        let playerSpeed = CGFloat(700)
        
        let viewLocation = recognizer.location(in: view)
        let sceneLocation = convertPoint(fromView: viewLocation)
        let gap = xDistance(a: sceneLocation, b: playerBucket.position)
        let realTime = travelTimeForDist(distance: gap, speed: playerSpeed)
        let moveToAction = SKAction.moveTo(x: sceneLocation.x, duration: realTime)
        playerBucket.run(moveToAction)
    }
    //calculate x distance
    func xDistance (a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow((a.x - b.x), 2.0))
    }
    
    
    func travelTimeForDist(distance: CGFloat, speed: CGFloat) -> TimeInterval{
        let time = distance/speed
        return TimeInterval(time)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        //TODO implement filled bucket, fix score counter
        if bodyA.categoryBitMask == dropCategory{
            bodyA.node?.removeFromParent()
        } else if bodyB.categoryBitMask == dropCategory{
            bodyB.node?.removeFromParent()
        }
    }
    
}
