//
//  GameScene.swift
//  swift-app
//
//  Created by Jamie Lo on 06/03/2026.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let bloodcell = SKSpriteNode(imageNamed: "bloodcell")
    let bloodcellCategory:UInt32 = 0x1 << 0;
    let borderCategory:UInt32 = 0x1 << 1;
    
    var isGameOver = false
    var gameStarted = false
    var score = 0 { didSet { scoreLabel.text = "Score: \(score)" } }
    var scoreLabel: SKLabelNode!
    var imageTaken = false
    var nameInput: UITextField?
    var submitBtn: UIButton?
    var selfieName: String?
    let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    var currentWaitDuration: TimeInterval = 3.0
    let minimumWaitDuration: TimeInterval = 1.0
    let decreaseAmount: TimeInterval = 0.5
    
    var currentPlaqueScale: CGFloat = 1.0
    let maxPlaqueScale: CGFloat = 2.5
    let scaleIncreaseAmount: CGFloat = 0.05
    
    var currentMoveDuration: TimeInterval = 4.0
    let minMoveDuration: TimeInterval = 1.0
    let moveDurationDecrease: TimeInterval = 0.1
    
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
        ceiling.position = CGPoint(x: size.width/2, y: size.height - ceilingHeight/2)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.categoryBitMask = borderCategory
        ceiling.physicsBody?.isDynamic = false
        ceiling.name = "ceiling"
        addChild(ceiling)

        let floorHeight: CGFloat = 100
        let floor = SKSpriteNode(color: UIColor(red: 188/255, green: 0/255, blue: 0/255, alpha: 1.0), size: CGSize(width: size.width, height: floorHeight))
        floor.position = CGPoint(x: size.width/2, y: floorHeight/2)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = borderCategory
        floor.physicsBody?.isDynamic = false
        floor.name = "floor"
        addChild(floor)
        
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        let hasValidText = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        submitBtn?.isEnabled = hasValidText
        submitBtn?.alpha = hasValidText ? 1.0 : 0.5
    }
    
    @objc func submitTapped() {
        print("Submit button was pressed!")
        appDelegate.dataModel.writeToFile(name: nameInput!.text!, score: score, selfieName: imageTaken ? selfieName! : nil)
        
        nameInput?.removeFromSuperview()
        submitBtn?.removeFromSuperview()
        
        // 3. Create a fresh instance of GameScene
        if let view = self.view {
            let restartScene = GameScene(size: self.size)
            restartScene.scaleMode = self.scaleMode
            
            // Optional: Add a smooth transition
            let transition = SKTransition.crossFade(withDuration: 0.5)
            
            // Present the new scene
            view.presentScene(restartScene, transition: transition)
        }
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
    
    func showTextInput() {
        guard let view = self.view else { return }
        
        let textFieldWidth: CGFloat = 200
        let textFieldHeight: CGFloat = 40
        
        let xPos = (view.bounds.width - textFieldWidth)/2
        let yPos = (view.bounds.height/2) - 100
        
        nameInput = UITextField(frame: CGRect(x: xPos, y: yPos, width: textFieldWidth, height: textFieldHeight))
        
        if let nameInput = nameInput {
            nameInput.placeholder = "Enter your name"
            nameInput.backgroundColor = .white
            nameInput.textColor = .black
            nameInput.textAlignment = .center
            nameInput.layer.cornerRadius = 8
            nameInput.autocorrectionType = .no
            nameInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            view.addSubview(nameInput)
            nameInput.becomeFirstResponder()
        }
    }
    
    func showSubmitBtn() {
        guard let view = self.view else { return }
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        
        let xPos = (view.bounds.width - buttonWidth)/2
        let yPos = (view.bounds.height/2) - 40
        submitBtn = UIButton(frame: CGRect(x: xPos, y: yPos, width: buttonWidth, height: buttonHeight))
        
        if let submitBtn = submitBtn {
            submitBtn.setTitle("Submit", for: .normal)
            submitBtn.setTitleColor(.black, for: .normal)
            submitBtn.backgroundColor = .white
            submitBtn.layer.cornerRadius = 8
            submitBtn.isEnabled = false
            submitBtn.alpha = 0.5
            submitBtn.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
            view.addSubview(submitBtn)
        }
    }
    
    func takeSelfie() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available on this device.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .front
        imagePicker.delegate = self
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let capturedImage = info[.originalImage] as? UIImage {
            let texture = SKTexture(image: capturedImage)
            let selfieNode = SKSpriteNode(texture: texture)
            
            selfieNode.size = CGSize(width: 200, height: 150)
            selfieNode.position = CGPoint(x: size.width/2, y: size.height/1.5)
            selfieNode.zPosition = 200
            selfieNode.zRotation = -1.57 // radians - turns it 90 degrees clockwise
            selfieNode.name = "selfieNode"
            
            addChild(selfieNode)
            self.imageTaken = true
            saveImage(image: capturedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("User closed the camera without taking an image.")
        self.imageTaken = false
    }
    
    func saveImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Could not compress image.")
            return
        }
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH-mm-ss"
        let timeString = timeFormatter.string(from: now)
        
        selfieName = dateString + "_" + timeString
        let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = documentDirURL.appendingPathComponent(selfieName!).appendingPathExtension("jpg")
        
        do {
            try imageData.write(to: imageURL)
            print("image write success")
        } catch let error as NSError {
            print("failed to write to url: \(imageURL), error: " + error.localizedDescription)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else { return }
        isGameOver = true
        gameStarted = false
        print("collision")
        run(sound)
        bloodcell.removeAllActions()
        removeAction(forKey: "spawningPlaques")
        
        let gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height - 300)
        gameOverLabel.zPosition = 100
                
        addChild(gameOverLabel)
        showTextInput()
        showSubmitBtn()
        takeSelfie()
    }
    
    func spawnPlaque() {
        let plaque = SKSpriteNode(imageNamed: "plaque.png")
        plaque.size = CGSize(width: 50, height: 50)
        plaque.setScale(currentPlaqueScale)
        
        let xPosition = size.width + plaque.size.width
        let yPosition = bloodcell.position.y
        plaque.position = CGPoint(x: xPosition, y: yPosition)
        
        plaque.physicsBody = SKPhysicsBody(rectangleOf: plaque.size)
        plaque.physicsBody?.isDynamic = false
        plaque.physicsBody?.categoryBitMask = borderCategory
        
        addChild(plaque)
        
        let distanceToMove = size.width + plaque.size.width * 2
        let moveLeft = SKAction.moveBy(x: -distanceToMove, y: 0, duration: currentMoveDuration)
        let remove = SKAction.removeFromParent()
        
        plaque.run(SKAction.sequence([moveLeft, remove]))
    }
    
    func startSpawningPlaques() {
        currentWaitDuration = 2.0
        spawnPlaqueLoop()
    }

    private func spawnPlaqueLoop() {
        let spawn = SKAction.run(spawnPlaque)
        let wait = SKAction.wait(forDuration: currentWaitDuration)
        let loopAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentWaitDuration = max(self.minimumWaitDuration, self.currentWaitDuration - self.decreaseAmount)
            self.currentPlaqueScale = min(self.maxPlaqueScale, self.currentPlaqueScale + self.scaleIncreaseAmount)
            self.currentMoveDuration = max(self.minMoveDuration, self.currentMoveDuration - self.moveDurationDecrease)
            self.spawnPlaqueLoop()
        }
        let sequence = SKAction.sequence([spawn, wait, loopAction])
        run(sequence, withKey: "spawningPlaques")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            if !gameStarted {
                gameStarted = true
                startScoring()
                startSpawningPlaques()
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
