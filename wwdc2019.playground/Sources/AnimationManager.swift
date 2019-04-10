import Foundation
import SpriteKit



class AnimationManager: NSObject {
    static let shared = AnimationManager.init()
    var atlas = SKTextureAtlas.init(named: "gameArts-hd")
    func texture(_ withType:SKTextureType) -> [SKTexture] {
        var generateTexture : [SKTexture] = []
        switch withType {
            
        case .boss:
            var tempTextrue : [SKTexture] = []
            for index in 1...7 {
                let tempNameText = "enemy2_blowup_\(index)"
                tempTextrue.append(atlas.textureNamed(tempNameText))
            }
            generateTexture = tempTextrue
            
        case .big:
            
            
            var tempTextrue : [SKTexture] = []
            for index in 1...7 {
                let tempNameText = "enemy2_blowup_\(index)"
                tempTextrue.append(atlas.textureNamed(tempNameText))
            }
            generateTexture = tempTextrue
            
            
            
        case .mid:
            var tempTextrue : [SKTexture] = []
            for index in 1...4 {
                let tempNameText = "enemy3_blowup_\(index)"
                tempTextrue.append(atlas.textureNamed(tempNameText))
            }
            generateTexture = tempTextrue
            
            
            
        case .small:
            var tempTextrue : [SKTexture] = []
            for index in 1...4 {
                let tempNameText = "enemy1_blowup_\(index)"
                tempTextrue.append(atlas.textureNamed(tempNameText))
            }
            generateTexture = tempTextrue
        default:
            return []
        }
        return generateTexture
        
    }
    
}
