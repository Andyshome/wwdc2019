

import UIKit
import SpriteKit
import MobileCoreServices

public class HomeScene: SKScene {
    var startNode:SKLabelNode?
    
    public init(size: CGSize , Mydifficulty:Int) {
        super.init(size: size)
        setup()
        var tempDifficulty = 0
        let valueNumber = [1,2,3,4,5,6,7]
        if valueNumber.contains(Mydifficulty) == false {
            tempDifficulty = 5
        } else {
            tempDifficulty = Mydifficulty
        }
        globalDifficulty = 1 - Double(tempDifficulty) / 10.0
        addNotes()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setup() {
        backgroundColor = .white
    }
    private func addNotes() {

        let logo = SKSpriteNode.init(imageNamed: "logo")
        logo.position = .init(x: size.width / 2, y: size.height * 0.75)
        logo.zPosition = 0
        logo.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(by: 0.7, duration: 0.5),SKAction.scale(to: 0.6, duration: 0.5)])))
        addChild(logo)
        
        let score = UserDefaults.standard.integer(forKey: "score")
        let resultlb = SKLabelNode.init(fontNamed: "Chalkduster")
        resultlb.text = "Best " + String(score)
        resultlb.fontSize = 40;
        resultlb.fontColor = .black
        resultlb.position = .init(x: size.width/2, y: size.height/2  + 50)
        addChild(resultlb)
        
        //2 Add a retry label below the result label
        startNode = SKLabelNode.init(fontNamed: "Chalkduster")
        startNode?.text = "GO!"
        startNode?.fontSize = 40
        startNode?.fontColor = .blue
        startNode?.position = .init(x: resultlb.position.x, y: resultlb.position.y * 0.8);
        //3 Give a name for this node, it will help up to find the node later.
        startNode?.name = "go"
        addChild(startNode!)
    }
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let frm = startNode!.frame
            if frm.contains(location) {
                go()
            }
        }
    }
    private func go(){
        let sence = GameScene.init(size: size)
        let t = SKTransition.moveIn(with: .up, duration: 0.3);
        view?.presentScene(sence, transition: t)
    }
}
