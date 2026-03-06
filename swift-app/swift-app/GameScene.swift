//
//  GameScene.swift
//  swift-app
//
//  Created by Jamie Lo on 06/03/2026.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    let bloodcell = SKSpriteNode(imageNamed: "bloodcell")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.red
        bloodcell.position = CGPoint(x:size.width/2, y:size.height/2)
        bloodcell.size = CGSize(width: 100, height: 100)
        addChild(bloodcell)
    }
}
