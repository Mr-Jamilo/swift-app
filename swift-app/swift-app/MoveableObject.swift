//
//  MoveableObject.swift
//  swift-app
//
//  Created by Jamie Lo on 22/03/2026.
//
import SpriteKit

///  A protocol for objects that can move within the SpriteKit scene
protocol MoveableObject where Self: SKSpriteNode {
    var categoryBitMask: UInt32 { get }
    func setupPhysics()
}

/**
 Provides a default implementation of the spawning and leftward movement behavior for moveable objects
 */
extension MoveableObject {
    /**
     Spawns the node into the provided scene at a given position, then moves it leftward across the screen

     - Parameters:
       - scene: The `SKScene` in which to spawn the node
       - position: The initial position where the node will appear
       - moveDuration: The duration over which the node moves leftward
     */
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

/// A `SKSpriteNode` representing a Statin object
class Statin: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    /// Initializes a Statin node with the given size and category bit mask
    ///
    /// Loads the texture "statin.png"
    /// - Parameters:
    ///   - size: The width and height of the node
    ///   - mask: The physics category bit mask
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "statin.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    /// Sets up a physics body matching the size of the Statin node
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// A `SKSpriteNode` representing a Plaque object
class Plaque: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    /// Initializes a Plaque node with the given size and category bit mask
    ///
    /// Loads the texture "plaque.png"
    /// - Parameters:
    ///   - size: The width and height of the node
    ///   - mask: The physics category bit mask
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "plaque.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    /// Sets up a physics body matching the size of the Plaque node
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// A `SKSpriteNode` representing an Unstable Plaque object
class UnstablePlaque: SKSpriteNode, MoveableObject {
    let categoryBitMask: UInt32
    
    /// Initializes an Unstable Plaque node with the given size and category bit mask
    ///
    /// Loads the texture "unstable_plaque.png"
    /// - Parameters:
    ///   - size: The width and height of the node
    ///   - mask: The physics category bit mask
    init(size: Int, mask: UInt32) {
        let texture = SKTexture(imageNamed: "unstable_plaque.png")
        self.categoryBitMask = mask
        super.init(texture: texture, color: .clear, size: CGSize(width: size, height: size))
    }
    
    /// Sets up a physics body matching the size of the Unstable Plaque node
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
