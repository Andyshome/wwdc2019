
import UIKit
import SpriteKit
import AVFoundation

private enum HeroBulletMode {
    case normal
     // determine you get supply or not and you will be set up on double bullet mode.
    case supply
}

public class GameScene: SKScene {
    private var monsters = [SKElementNode]()
    private var arms = [SKElementNode]()
    private var hero = SKElementNode.init(type: .hero)
    private var monsterBullets = [SKSpriteNode]()
    lazy private var armSoundAction = { () -> SKAction in
        let action = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
        return action
    }()
    private var player:AVAudioPlayer?
    private var scorLb:SKLabelNode?
    private var score = 0
    private var difficulty : Double = 0
    private var shouldMove = false
    private var supply = TextureManager.shared.node(.supply)
    private var boss = SKElementNode.init(type: .boss)
    private var totalGeneratedMonsterCount = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override init(size: CGSize) {
        super.init(size: size)
        setup()
        addNodes()
    }
    func setup() {
        backgroundColor = .white
        let bgNode = SKSpriteNode.init(imageNamed: "bg")
        bgNode.position = .zero
        bgNode.zPosition = 0
        bgNode.anchorPoint = .zero
        bgNode.size = size
        addChild(bgNode)
        
        guard let path = Bundle.main.path(forResource: "bgm", ofType: "mp3") else {
            return
        }
        let url = URL.init(fileURLWithPath: path)
        do{
            try player = AVAudioPlayer.init(contentsOf: url)
        }catch let e {
            print(e.localizedDescription)
            return
        }
        player?.numberOfLoops = -1
        player?.volume = 0.8
        player?.prepareToPlay()
        player?.play()
    }
}
//add node
extension GameScene {
    private func addNodes() {
        addHero()
        addScoreLb()
        addMonsters()
    }
    private func addScoreLb() {
        scorLb = SKLabelNode.init(fontNamed: "Chalkduster")
        scorLb?.text = "0"
        scorLb?.fontSize = 20
        scorLb?.fontColor = .black
        scorLb?.position = .init(x: 50, y: size.height - 40)
        addChild(scorLb!)
    }
   // add hero to scene to set up
    private func addHero() {
        //set up frame for hero
        hero.position = .init(x: size.width/2, y: hero.size.height/2)
        hero.name = "hero"
        addChild(hero)
        
        //make the hero can shoot by him self
        weak var wkself = self
        let shootAction = SKAction.run {
            wkself?.shoot()
        }
        let wait = SKAction.wait(forDuration: 0.2)
        let sequenceAction = SKAction.sequence([shootAction,wait])
        let repeatShootAction = SKAction.repeatForever(sequenceAction)
        run(repeatShootAction)
    }
    private func shoot() {
        guard hero.shouldShoot else {
            return
        }
        if hero.buff == .none {
            let armsNode = SKElementNode.init(type: .bullet)
            //fire bullet from it's position
            armsNode.position = hero.position
            //add bullet
            addChild(armsNode)
            arms.append(armsNode)
            //calculate the distence from it's origin place
            let distance = size.height - armsNode.position.y
            let speed = size.height
            //calculate time
            let duration = distance/speed
            let moveAction = SKAction.moveTo(y: size.height, duration: TimeInterval(duration))
            weak var wkarms = armsNode
            weak var wkself = self
            //add action
            let group = SKAction.group([moveAction,armSoundAction])
            armsNode.run(group, completion: {
                wkarms?.removeFromParent()
                let index = wkself?.arms.index(of: wkarms!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
        }else if hero.buff == .doubleBullet {
            let bullet1 = SKElementNode.init(type: .bullet)
            bullet1.position = .init(x: hero.position.x - hero.size.width/4, y: hero.position.y)
            addChild(bullet1)
            let bullet2 = SKElementNode.init(type: .bullet)
            bullet2.position = .init(x: hero.position.x + hero.size.width/4, y: hero.position.y)
            addChild(bullet2)
            arms.append(bullet1)
            arms.append(bullet2)
            
            let distance = size.height - bullet1.position.y
            let speed = size.height

            let duration = distance/speed
            let moveAction = SKAction.moveTo(y: size.height, duration: TimeInterval(duration))
            weak var wkbullet1 = bullet1
            weak var wkbullet2 = bullet2
            weak var wkself = self
            //fire two bullets
            let group = SKAction.group([moveAction,armSoundAction])
            bullet1.run(group, completion: {
                wkbullet1?.removeFromParent()
                let index = wkself?.arms.index(of: wkbullet1!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
            bullet2.run(moveAction, completion: {
                wkbullet2?.removeFromParent()
                let index = wkself?.arms.index(of: wkbullet2!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
        }else{
            
        }
    }
    private func addMonsters() {
        weak var wkself = self
        //add monster automaticly
        let addMonsterAction = SKAction.run {
            wkself?.generateMonster()
        }
        let waitAction = SKAction.wait(forDuration: globalDifficulty)
        let bgSequence = SKAction.sequence([addMonsterAction,waitAction])
        let repeatAction = SKAction.repeatForever(bgSequence)
        
        run(repeatAction)
    }
    private func generateMonster() {
        showSupplyeIfNeed()
        if boss.parent != nil {
            return
        }
        let bossGenerateStandard = 100 - Int(globalDifficulty * 100) + 10
        if totalGeneratedMonsterCount % bossGenerateStandard == 0 && totalGeneratedMonsterCount > 0 {
            boss = SKElementNode.init(type: .boss)
            bossShow()
            return
        }
        weak var wkself = self
    
        let minduration:Int = 4
        let maxduration:Int = 5
        var duration = Int(arc4random_uniform((UInt32(maxduration - minduration)))) + minduration
        var bulletCount = 0
        //random generate bullets
        var enemyType:SKTextureType = .small
        if totalGeneratedMonsterCount == 0 {
            enemyType = .small
        }else if totalGeneratedMonsterCount % 10 == 0 && totalGeneratedMonsterCount % 20 != 0 {
            enemyType = .mid
            duration = maxduration
            bulletCount = 2
        }else if totalGeneratedMonsterCount % 20 == 0 {
            enemyType = .big
            duration = maxduration
            bulletCount = 4
        }else{
            enemyType = .small
        }
        let monster = SKElementNode.init(type: enemyType)
        let minx:Int = Int(monster.size.width / 2)
        let maxx:Int = Int(size.width - monster.size.width / 2)
        let gapx:Int = maxx - minx
        let xpos:Int = Int(arc4random_uniform(UInt32(gapx))) + minx
        monster.position = .init(x: CGFloat(xpos), y: (size.height + monster.size.height/2))
        addChild(monster)
        totalGeneratedMonsterCount += 1
        monsters.append(monster)
        //monster fire bullets
        if bulletCount > 0 {
            monsterShoot(monster: monster, bulletCount: bulletCount, shootDuration: 0.5, dismisDuration: duration)
        }
        //move
        let moveAction = SKAction.moveTo(y: -monster.size.height/2, duration: TimeInterval(duration))
        //remove
        let removeAction = SKAction.run {
            monster.removeFromParent()
            let index = wkself?.monsters.index(of: monster)
            if index != nil {
                wkself?.monsters.remove(at: index!)
            }
            //end game
        }
        //add action
        monster.run(SKAction.sequence([moveAction,removeAction]))
    }
    private func showSupplyeIfNeed() {
        if arc4random_uniform(100) < 96 {
            return
        }
        if supply.parent != nil {
            return
        }
        let supplyx = CGFloat(arc4random_uniform(UInt32(size.width - supply.size.width))) + supply.size.width/2
        supply.removeAllActions()
        supply.position = .init(x: supplyx, y: size.height + size.height + supply.size.height/2)
        addChild(supply)
        let move = SKAction.moveTo(y: -supply.size.height/2, duration: TimeInterval(5))
        supply.run(move, completion: {
            self.supply.removeFromParent()
        })
    }
    private func bossShow() {
        let reference = score/100
        if monsters.count > 0 {
            monsters.forEach{
                $0.removeFromParent()
            }
            monsters.removeAll()
        }
        boss.removeAllActions()
        hero.shouldShoot = false
        boss.position = .init(x: size.width/2, y: size.height + boss.size.height/2)
        addChild(boss)
        monsters.append(boss)
        let hp = 80+reference * 10
        boss.hp = UInt(hp)
        let monsterShootDuration = 0.5 - 0.01 * CGFloat(reference)
        totalGeneratedMonsterCount += 1
        let bossAppearWait = SKAction.wait(forDuration: 3)
        let appear = SKAction.moveTo(y: size.height-boss.size.height/2, duration: 3)
        SKAction.sequence([bossAppearWait, appear])
        let center2Left = SKAction.moveTo(x: boss.size.width/2, duration: 3)
        weak var wkself = self
        let heroOn = SKAction.run {
            wkself?.hero.shouldShoot = true
        }
        let move2Right = SKAction.moveTo(x: size.width - boss.size.width/2, duration: 6)
        let move2Left = SKAction.moveTo(x: boss.size.width/2, duration: 6)
        let moveRepeat = SKAction.repeatForever(SKAction.sequence([move2Right,move2Left]))
        let move = SKAction.sequence([center2Left,moveRepeat])
        let group1 = SKAction.group([move, heroOn])
        
        let bossShoot = SKAction.run({
            wkself?.monsterShoot(monster: wkself!.boss, bulletCount: 6, shootDuration: TimeInterval(monsterShootDuration), dismisDuration: 3)
        })
        let boosShootWait = SKAction.wait(forDuration: 4)
        let repeatShoot = SKAction.repeatForever(SKAction.sequence([bossShoot, boosShootWait]))
        let group2 = SKAction.group([group1,repeatShoot])
        boss.run(SKAction.sequence([appear, group2]))
    }
    private func monsterShoot(monster:SKElementNode, bulletCount:Int, shootDuration:TimeInterval,dismisDuration:Int) {
        weak var wkself = self
        let wait = SKAction.wait(forDuration: shootDuration)
        let shoot = SKAction.run {
            if monster.parent == nil {
                return
            }
            let bullet = SKSpriteNode.init(imageNamed: "monster_bullet")
            wkself?.addChild(bullet)
            wkself?.monsterBullets.append(bullet)
            bullet.position = monster.position
            let endPos = CGPoint.init(x: wkself!.hero.position.x, y: -bullet.size.height/2)
            let move = SKAction.move(to: endPos , duration: TimeInterval(dismisDuration))
            weak var wkbullet = bullet
            bullet.run(move, completion: {
                wkbullet?.removeFromParent()
                let index = wkself?.monsterBullets.index(of: wkbullet!)
                if index != nil {
                    wkself?.monsterBullets.remove(at: index!)
                }
            })
        }
        let sequence = SKAction.sequence([wait,shoot])
        let `repeat` = SKAction.repeat(sequence, count: bulletCount)
        run(`repeat`)
    }
}
//MARK: -
//MARK: 游戏结束
extension GameScene {
    private func gameOver() {
        player?.stop()
        let lose = LoseScene.init(size: size)
        lose.score = score
        refreshRecordIfNeed()
        let transation = SKTransition.moveIn(with: .up, duration: 0.5)
        view?.presentScene(lose, transition: transation)
    }
    //刷新历史纪录
    private func refreshRecordIfNeed() {
        let history = UserDefaults.standard.integer(forKey: "score")
        if score > history {
            UserDefaults.standard.set(score, forKey: "score")
            UserDefaults.standard.synchronize()
        }
    }
}

extension GameScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        //move hero
        var frm = hero.frame
        frm = .init(x: frm.origin.x, y: frm.origin.y, width: frm.size.width + 100, height: frm.size.height + 100)
        if !frm.contains(location) {
            shouldMove = false
        }else{
            shouldMove = true
        }
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  shouldMove else {
            return
        }
        let touch = touches.first!
        let previousPosition = touch.previousLocation(in: view)
        let currentPosition = touch.location(in: view)
        let offsetx = currentPosition.x - previousPosition.x
        let offsety = currentPosition.y - previousPosition.y
        let x = hero.position.x + offsetx
        guard  x>=hero.size.width/2, x <= size.width-hero.size.width/2 else {
            return
        }
        let y = hero.position.y - offsety
        guard y>=hero.size.height/2, y <= size.height-hero.size.height/2 else {
            return
        }
        hero.position = .init(x: x , y: y)
    }
}
//intersect monitoring
extension GameScene {
    private func score(_ withType:SKTextureType) -> Int {
        if withType == .small {
            return 1
        }else if withType == .mid {
            return 2
        }else if withType == .big {
            return 3
        }else if withType == .boss {
            return 5
        }else {
            return 0
        }
    }
    public override func update(_ currentTime: TimeInterval) {
        for monster_bullet in monsterBullets {
            if monster_bullet.frame.intersects(hero.frame) {
                gameOver()
                return
            }
        }
        for monster in monsters {
            if monster.frame.intersects(hero.frame) {
                gameOver()
                return
            }
            for arm in arms {
                if arm.frame.intersects(monster.frame) {
                    //remove bullet
                    arm.removeFromParent()
                    let armindex = arms.index(of: arm)
                    if armindex != nil {
                        arms.remove(at: armindex!)
                    }
                    //refresh hp
                    if(monster.alive()) {
                        monster.hp -= 1
                        if monster.alive() {
                            continue
                        }
                    }
                    let monsterAnimationType = monster.type
                    let animationArray : [SKTexture] = AnimationManager.shared.texture(monsterAnimationType)
                    if monsterAnimationType == .big || monsterAnimationType == .mid || monsterAnimationType == .small {
                            monster.run(SKAction.animate(with: animationArray, timePerFrame: 0.1)) {
                            monster.removeFromParent()
                        }
                        
                    }
                    //if not alive, remove mosnter
                    if monster == boss {
                        
                        let bossAnimationArray : [SKTexture] = AnimationManager.shared.texture(SKTextureType.big)
                        boss.removeAllActions()
                        monster.run(SKAction.animate(with: bossAnimationArray, timePerFrame: 0.2)) {
                            
                            monster.removeFromParent()
                        }
                    }
                    let monsterindex = monsters.index(of: monster)
                    if monsterindex != nil {
                        monsters.remove(at: monsterindex!)
                    }
                    //refresh score
                    score += score(monster.type)
                    scorLb?.text = String(score)
                    refreshRecordIfNeed()
                }
            }
        }
        if supply.parent != nil {
            if supply.frame.intersects(hero.frame) {
                //get supply, double bullet mode.
                supply.removeFromParent()
                removeAction(forKey: "supply_key")
                hero.buff = .doubleBullet
                let last = SKAction.wait(forDuration: 15)
                let reset = SKAction.run {
                    self.hero.buff = .none
                }
                let sequnce = SKAction.sequence([last,reset])
                run(sequnce, withKey: "supply_key")
            }
        }
    }
}
