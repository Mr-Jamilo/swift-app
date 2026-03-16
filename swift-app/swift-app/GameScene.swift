//
//  GameScene.swift
//  swift-app
//
//  Created by Jamie Lo on 06/03/2026.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let bloodcell = SKSpriteNode(imageNamed: "bloodcell")
    let bloodcellCategory:UInt32 = 0x1 << 0;
    let borderCategory:UInt32 = 0x1 << 1;
    
    var isGameOver = false
    var gameStarted = false
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    var scoreLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.red
        bloodcell.position = CGPoint(x:size.width/4, y:size.height/2)
        bloodcell.size = CGSize(width: 50, height: 50)
        bloodcell.physicsBody = SKPhysicsBody(rectangleOf: bloodcell.frame.size)
        bloodcell.physicsBody?.categoryBitMask = bloodcellCategory
        bloodcell.physicsBody?.collisionBitMask = borderCategory | bloodcellCategory
        bloodcell.physicsBody?.contactTestBitMask = borderCategory
        bloodcell.physicsBody?.isDynamic = true
        addChild(bloodcell)
        
        let ceilingHeight: CGFloat = 100
        let ceiling = SKSpriteNode(color: UIColor(red: 188/255, green: 0/255, blue: 0/255, alpha: 1.0), size: CGSize(width: size.width, height: ceilingHeight))
        ceiling.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ceiling.position = CGPoint(x: size.width / 2, y: size.height - ceilingHeight / 2)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.categoryBitMask = borderCategory
        ceiling.physicsBody?.isDynamic = false
        ceiling.name = "ceiling"
        addChild(ceiling)

        let floorHeight: CGFloat = 100
        let floor = SKSpriteNode(color: UIColor(red: 188/255, green: 0/255, blue: 0/255, alpha: 1.0), size: CGSize(width: size.width, height: floorHeight))
        floor.position = CGPoint(x: size.width / 2, y: floorHeight / 2)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = borderCategory
        floor.physicsBody?.isDynamic = false
        floor.name = "floor"
        addChild(floor)
        
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    func startScoring() {
        let wait = SKAction.wait(forDuration: 1.0)
        let increment = SKAction.run { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            self.score += 1
        }
        let sequence = SKAction.sequence([wait, increment])
        run(SKAction.repeatForever(sequence), withKey: "scoringAction")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        isGameOver = true
        gameStarted = false
        print("collision")
        bloodcell.removeAllActions()
        
        let gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.zPosition = 100
        
        addChild(gameOverLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            if !gameStarted {
                gameStarted = true
                startScoring()
            }
            bloodcell.removeAllActions()
            let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 0.3)
            bloodcell.run(SKAction.repeatForever(moveUp))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            bloodcell.removeAllActions()
            let playerDown = SKAction.move(to: CGPoint(x: size.width/4, y: 0), duration: 3)
            let sequence = SKAction.sequence([playerDown])
            bloodcell.run(sequence)
        }
    }
}
