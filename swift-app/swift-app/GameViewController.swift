//
//  GameViewController.swift
//  swift-app
//
//  Created by Jamie Lo on 21/02/2026.
//

import UIKit
import SpriteKit

/// A view controller for displaying the game scene
class GameViewController: UIViewController {
    /// Creates and loads the game scene
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}
