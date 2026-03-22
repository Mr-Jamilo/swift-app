//
//  MoveableObject.swift
//  swift-app
//
//  Created by Jamie Lo on 22/03/2026.
//
import SpriteKit

protocol MoveableObject where Self: SKSpriteNode {
    var categoryBitMask: UInt32 { get }
    func setupPhysics()
}

extension MoveableObject {
    func spawn(in scene: SKScene, at position: CGPoint, moveDuration: TimeInterval) {
        self.position = position
        self.setupPhysics()
        
        self.physicsBody?.categoryBitMask = self.categoryBitMask
        self.physicsBody?.isDynamic = false
        
        scene.addChild(self)
        
        let distanceToMove = scene.size.width + self.size.width * 2
        let moveLeft = SKAction.moveBy(x: -distanceToMove, y: 0, duration: moveDuration)
        let remove = SKAction.removeFromParent()
        
        self.run(SKAction.sequence([moveLeft, remove]))
    }
}

class Statin: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "statin.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class Plaque: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "plaque.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class UnstablePlaque: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "unstable_plaque.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
