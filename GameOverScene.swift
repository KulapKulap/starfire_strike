import SpriteKit

class GameOverScene: SKScene {
    var starField2: SKEmitterNode?
    var gameOverNode: SKLabelNode?
    var scoreNode: SKLabelNode?
    var newButtonNode: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        if let starField = self.childNode(withName: "starfield") as? SKEmitterNode {
            starField2 = starField
            starField2?.advanceSimulationTime(10)
        }
        
        if let gameOver = self.childNode(withName: "gameOverLabel") as? SKLabelNode {
            gameOverNode = gameOver
        }
        
        if let score = self.childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreNode = score
        }
        
        if let newButton = self.childNode(withName: "newButton") as? SKSpriteNode {
            newButtonNode = newButton
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self), let nodeTouched = self.nodes(at: location).first {
            if nodeTouched.name == "newButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}

