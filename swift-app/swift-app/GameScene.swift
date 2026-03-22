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
    let dangerCategory:UInt32 = 0x1 << 1;
    let powerupCategory:UInt32 = 0x1 << 2;
    
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
        let swipeDown = UISwipeGestureRecognizer(target:self, action: #selector(swipeDownGesture(_ :)))
        swipeDown.direction = .down
        let swipeUp = UISwipeGestureRecognizer(target:self, action: #selector(swipeUpGesture(_ :)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(swipeUp)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.red
        bloodcell.position = CGPoint(x:size.width/4, y:size.height/2)
        bloodcell.size = CGSize(width: 50, height: 50)
        bloodcell.physicsBody = SKPhysicsBody(rectangleOf: bloodcell.frame.size)
        bloodcell.physicsBody?.categoryBitMask = bloodcellCategory
        bloodcell.physicsBody?.collisionBitMask = dangerCategory | powerupCategory | bloodcellCategory
        bloodcell.physicsBody?.contactTestBitMask = dangerCategory | powerupCategory
        bloodcell.physicsBody?.isDynamic = true
        addChild(bloodcell)
        
        let ceilingHeight: CGFloat = 100
        let ceiling = SKSpriteNode(color: UIColor(red: 188/255, green: 0/255, blue: 0/255, alpha: 1.0), size: CGSize(width: size.width, height: ceilingHeight))
        ceiling.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ceiling.position = CGPoint(x: size.width/2, y: size.height - ceilingHeight/2)
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.categoryBitMask = dangerCategory
        ceiling.physicsBody?.isDynamic = false
        ceiling.name = "ceiling"
        addChild(ceiling)

        let floorHeight: CGFloat = 100
        let floor = SKSpriteNode(color: UIColor(red: 188/255, green: 0/255, blue: 0/255, alpha: 1.0), size: CGSize(width: size.width, height: floorHeight))
        floor.position = CGPoint(x: size.width/2, y: floorHeight/2)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.categoryBitMask = dangerCategory
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
    
    @objc func swipeDownGesture(_ sender: UISwipeGestureRecognizer) {
        print("swipe down")
        if !isGameOver && gameStarted {
            bloodcell.removeAllActions()
            let moveUp = SKAction.moveBy(x: 0, y: -50, duration: 0.1)
            bloodcell.run(SKAction.repeatForever(moveUp))
        }
    }
    
    @objc func swipeUpGesture(_ sender: UISwipeGestureRecognizer) {
        print("swipe up")
        if !isGameOver && gameStarted {
            bloodcell.removeAllActions()
            let moveDown = SKAction.moveBy(x: 0, y: 50, duration: 0.1)
            bloodcell.run(SKAction.repeatForever(moveDown))
        }
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
        
        if let view = self.view {
            let restartScene = GameScene(size: self.size)
            restartScene.scaleMode = self.scaleMode
            let transition = SKTransition.crossFade(withDuration: 0.5)
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
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case bloodcellCategory | dangerCategory:
            print("gameover")
            isGameOver = true
            gameStarted = false
            run(sound)
            bloodcell.removeAllActions()
            removeAction(forKey: "spawningObjects")
            
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
        case bloodcellCategory | powerupCategory:
            print("power-up collected")
        default:
            break
        }
    }
    
    func startSpawning() {
        currentWaitDuration = 2.0
        spawnObjectsLoop()
    }
    
    func spawnRandomObject() {
        let randomChoice = Int.random(in: 0...2)
        let object: (SKSpriteNode & MoveableObject)?

        switch randomChoice {
        case 0:
            let plaque = Plaque(size: 50, mask: dangerCategory)
            plaque.setScale(currentPlaqueScale)
            object = plaque
        case 1:
            object = Statin(size: 30, mask: powerupCategory)
        case 2:
            object = UnstablePlaque(size: 20, mask: dangerCategory)
        default:
            object = nil
        }
        guard let object = object else { return }

        let floorHeight: CGFloat = 100
        let ceilingHeight: CGFloat = 100
        let minY = floorHeight + (object.size.height / 2)
        let maxY = size.height - ceilingHeight - (object.size.height / 2)
        let randomY = CGFloat.random(in: minY...maxY)
        let xPosition = size.width + object.size.width
        let startPos = CGPoint(x: xPosition, y: randomY)

        object.spawn(in: self, at: startPos, moveDuration: currentMoveDuration)
    }
    
    private func spawnObjectsLoop() {
        let spawn = SKAction.run(spawnRandomObject)
        let wait = SKAction.wait(forDuration: currentWaitDuration)
        
        let loopAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.currentWaitDuration = max(self.minimumWaitDuration, self.currentWaitDuration - self.decreaseAmount)
            self.currentPlaqueScale = min(self.maxPlaqueScale, self.currentPlaqueScale + self.scaleIncreaseAmount)
            self.currentMoveDuration = max(self.minMoveDuration, self.currentMoveDuration - self.moveDurationDecrease)
            self.spawnObjectsLoop()
        }
        
        let sequence = SKAction.sequence([spawn, wait, loopAction])
        run(sequence, withKey: "spawningObjects") // Replaced the 3 action keys with 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver {
            if !gameStarted {
                gameStarted = true
                startScoring()
                startSpawning()
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
