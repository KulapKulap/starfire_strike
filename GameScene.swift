//mixkit.co
//www.flaticon.com
//pixabay.com/sound-effects

import SpriteKit
import GameplayKit
import CoreMotion
import UIKit
import AVFoundation




//hui
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //for physics SKPhysicsContactDelegate
    var starfield: SKEmitterNode!
    var player:SKSpriteNode!
    //player.setScale(2) - bigger two times
    
    //for score
    var scoreLabel:SKLabelNode!
    var score:Int=0{
        didSet{
            scoreLabel.text="score: \(score)"
        }
    }
    
    
    
   
    
    
    
    //for timer
    var gameTimer:Timer!
    var aliens=["alien","alien2","alien3"]
    
    let alienCategory: UInt32 = 0x1 << 1
    let bulletCategory: UInt32 = 0x1 << 0
    
    //accelerometer
    let motionManager = CMMotionManager()
    var xAccelerate:CGFloat = 0
    
    var finalScore:Int=0
    var backgroundMusicPlayer: AVAudioPlayer!
    var isMusicMuted: Bool = false
    var muteIcon: SKSpriteNode!
    var isGamePaused: Bool = false
    
    //----

    //----

    
    
    
    
    
    
    //start functions
    override func didMove(to view: SKView) {
        //add bg music
        if let musicURL = Bundle.main.url(forResource: "bg", withExtension: "mp3") {
                backgroundMusicPlayer = try? AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer.play()
            }
        
        starfield=SKEmitterNode(fileNamed:"Starfield")
        starfield.position=CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position=CGPoint(x:50, y:30)
        self.addChild(player)
        
        //for physics
        self.physicsWorld.gravity=CGVector(dx:0, dy:0)
        self.physicsWorld.contactDelegate=self
        
        //for score
        scoreLabel=SKLabelNode(text:"score:0")
        scoreLabel.fontName="AmericanTypewriter-Bold"
        scoreLabel.fontSize=30
        scoreLabel.fontColor=UIColor.white
        scoreLabel.position=CGPoint(x:100, y:UIScreen.main.bounds.height - 70)
        score=0
        self.addChild(scoreLabel)
        
        //add RestartGame button
        let restartButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                restartButton.text = "restart"
                restartButton.fontSize = 30
                restartButton.fontColor = .white
                restartButton.position = CGPoint(x: size.width - 100, y: size.height - 70) // Top-right corner
                restartButton.name = "restartButton"
                addChild(restartButton)
        
        muteIcon = SKSpriteNode(imageNamed: "mute_icon") // Replace "mute_icon" with the actual name of your mute icon image
        muteIcon.size = CGSize(width: 30, height: 30) // Set the size as needed
        muteIcon.position = CGPoint(x: size.width / 2, y: size.height - 60)
        muteIcon.name = "muteButton"
        addChild(muteIcon)
        
        let pauseButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
                pauseButton.text = "pause"
                pauseButton.fontSize = 32
                pauseButton.fontColor = .white
                pauseButton.position = CGPoint(x: size.width/2, y: size.height - 110)
                pauseButton.name = "pauseButton"
                addChild(pauseButton)
        
        
        
        


        
        
        
        
        
        
        var timeInterval = 0.75
        if UserDefaults.standard.bool(forKey: "hard"){
            timeInterval = 0.3
        }
        
        //timer for enemies
        gameTimer=Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector:#selector(addAlien), userInfo:nil, repeats: true)
        
        
        //accelerometer
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                    
            //data from accelerometer
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
        
        
        
        
       

        
}
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        // Get the player's width to make adjustments
        let playerWidth = player.size.width
        
        // Adjust the player's position if it goes beyond the screen bounds
        if player.position.x < -playerWidth/2 {
            player.position.x = UIScreen.main.bounds.width + playerWidth/2
        } else if player.position.x > UIScreen.main.bounds.width + playerWidth/2 {
            player.position.x = -playerWidth/2
        }
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node as? SKSpriteNode,
              let nodeB = contact.bodyB.node as? SKSpriteNode else {
            return
        }

        var bulletNode: SKSpriteNode
        var alienNode: SKSpriteNode

        if nodeA.name == "bullet" {
            bulletNode = nodeA
            alienNode = nodeB
        } else {
            bulletNode = nodeB
            alienNode = nodeA
        }

        if (alienNode.physicsBody?.categoryBitMask ?? 0) == alienCategory &&
           (bulletNode.physicsBody?.categoryBitMask ?? 0) == bulletCategory {
            collisionElements(bulletNode: bulletNode, alienNode: alienNode)
        }
    }

    
    
    
    
    
    
    
    func collisionElements(bulletNode:SKSpriteNode, alienNode:SKSpriteNode){
        //let explosion = SKEmitterNode(fileNamed: "explosion")
        //explosion?.position = alienNode.position
        //self.addChild(explosion!)
            
            
            //self.run(SKAction.playSoundFileNamed("explosion_sound.wav", //waitForCompletion: false))
            
            bulletNode.removeFromParent()
            alienNode.removeFromParent()
        
        //self.run(SKAction.wait(forDuration: 2)){
        //    explosion?.removeFromParent()
        //}
        

            
           
            
            score += 1
            if score == 10 {
                finalScore=score
                showGameOver()
                stopGame()
            }
        
        
        
        }
    
    
   

    
    func showGameOver() {
        
        backgroundMusicPlayer.stop()
        
        let gameOverLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        gameOverLabel.text = "game over"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)

        

        
        
        
        let finalScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        finalScoreLabel.text = "final score: \(finalScore)"
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(finalScoreLabel)
        
        // Creating a button to go to the MainMenu
        let button = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        button.text = "restart"
        button.fontSize = 24
        button.fontColor = .white
        button.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100)
        button.name = "mainMenuButton" // Set a name for the button node
        addChild(button)
        
        
        let goToMainMenuButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        goToMainMenuButton.text = "main menu"
        goToMainMenuButton.fontSize = 24
        goToMainMenuButton.fontColor = .white
        goToMainMenuButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 150)
        goToMainMenuButton.name = "goToMainMenuButton" // Set a name for the button node
        addChild(goToMainMenuButton)
        
        let exitButton = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        exitButton.text = "exit"
        exitButton.fontSize = 24
        exitButton.fontColor = .white
        exitButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 200)
        exitButton.name = "exitButton" // Set a name for the exit button node
        addChild(exitButton)
        
        
        
        
        
         
        
        
        
        if let restartButton = childNode(withName: "restartButton") {
                restartButton.isHidden = true
            }
        
        
    }
    
    
    func stopGame() {
        self.isPaused = true
    }
    
    
    
    func fire(touch: UITouch) {
        let touchLocation = touch.location(in: self)

        // Check if the touch is near the top of the screen
        let topMargin: CGFloat = 100
        if touchLocation.y < UIScreen.main.bounds.height - topMargin {
            // Tap is not near the top, proceed with firing
            run(SKAction.playSoundFileNamed("bullet-sound.mp3", waitForCompletion: false))

            let bullet = SKSpriteNode(imageNamed: "bullet")
            bullet.position = player.position
            bullet.position.y += 5

            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
            bullet.physicsBody?.isDynamic = true
            bullet.physicsBody?.categoryBitMask = bulletCategory
            bullet.physicsBody?.contactTestBitMask = alienCategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true

            // Add to the screen
            self.addChild(bullet)

            let animDuration: TimeInterval = 0.3
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
            actions.append(SKAction.removeFromParent())
            bullet.run(SKAction.sequence(actions))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "mainMenuButton" {
                restartGame()
            } else if touchedNode.name == "restartButton" {
                restartGame()
            } else if touchedNode.name == "exitButton" {
                terminateApp()
            } else if touchedNode.name == "goToMainMenuButton" {
                goToMainMenu()
            } else if touchedNode.name == "muteButton" {
                toggleMusicMute()
            } else if touchedNode.name == "pauseButton" {
                pauseButtonTapped(touch)
            }else {
                fire(touch: touch)
            }
        }
    }
    
    @objc func pauseButtonTapped(_ sender: UITouch) {
            if let scene = self.scene {
                if isGamePaused {
                    scene.isPaused = false
                    isGamePaused = false
                    // Optionally, you can add code for the game resume state
                    print("Game Resumed")
                } else {
                    scene.isPaused = true
                    isGamePaused = true
                    // Optionally, you can add code for the game pause state
                    print("Game Paused")
                }
            }
        }
    
    
    func toggleMusicMute() {
        isMusicMuted = !isMusicMuted
        backgroundMusicPlayer.volume = isMusicMuted ? 0.0 : 1.0

        // Change the texture of the mute icon based on the mute state
        if isMusicMuted {
            muteIcon.texture = SKTexture(imageNamed: "unmute_icon")
        } else {
            muteIcon.texture = SKTexture(imageNamed: "mute_icon")
        }
    }
    
    
    

    
    
    func goToMainMenu() {
        // Assuming you have a MainMenuScene class
        if let mainMenuScene = MainMenu(fileNamed: "MainMenu") {
            mainMenuScene.scaleMode = .aspectFill
            
            if let view = self.view {
                let transition = SKTransition.fade(withDuration: 0.5)
                view.presentScene(mainMenuScene, transition: transition)
            }
        }
    }
    
    func restartGame() {
        score = 0
        if let view = self.view {
            let transition = SKTransition.fade(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            view.presentScene(gameScene, transition: transition)
        }
    }
    
    
    func terminateApp() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }

    
    
   


    
    
    
    

    
    
    
    
    
    @objc func addAlien(){
        if score >= 10 {
                return
            }
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        
        //for layout
        let randomPos=GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        
        //int->float
        let pos=CGFloat(randomPos.nextInt())
        
        //enemies position
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
        
        
        //physics
        alien.physicsBody=SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic=true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        //add to the screen
        self.addChild(alien)
        
        let animDuration:TimeInterval = 6
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x:pos,y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actions))
        
        
        
    }

    
    
    
 




        
    
    
    
    
}
