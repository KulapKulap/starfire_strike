import SpriteKit

class MainMenu: SKScene {
    var starField: SKEmitterNode?
    var newGameButtonNode: SKSpriteNode?
    var levelButtonNode: SKSpriteNode?
    var labelLevelNode: SKLabelNode?
    
    override func didMove(to view: SKView) {
        if let starField = self.childNode(withName: "starfieldAnim") as? SKEmitterNode {
            self.starField = starField
            starField.advanceSimulationTime(10)
        }

        if let newGameButton = self.childNode(withName: "newGameButton") as? SKSpriteNode {
            self.newGameButtonNode = newGameButton
        }

        if let levelButton = self.childNode(withName: "levelButton") as? SKSpriteNode {
            self.levelButtonNode = levelButton
        }

        if let labelLevelButton = self.childNode(withName: "labelLevelButton") as? SKLabelNode {
            self.labelLevelNode = labelLevelButton
        }
        
        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            labelLevelNode?.text = "hard"
        } else {
            labelLevelNode?.text = "easy"
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self), let nodesArray = self.nodes(at: location).first {
            if nodesArray.name == "newGameButton", let sceneView = self.view {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                sceneView.presentScene(gameScene, transition: transition)
            } else if nodesArray.name == "levelButton" {
                changeLevel()
            }
        }
    }
    
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if labelLevelNode?.text == "easy" {
            labelLevelNode?.text = "hard"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode?.text = "easy"
            userLevel.set(false, forKey: "hard")
        }
        
        userLevel.synchronize()
    }
}

