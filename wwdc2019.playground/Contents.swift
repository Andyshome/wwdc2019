/*:
 ### Overview
 In this playground, you will configure the game **Plane War**. This is an infinited game.
 The goal of this game **Plane War** is to try to servive as long as you can.
 
 ### Rules
The following are the **rules** for the game.
 
There are three different kinds of enemy in this game.
 * Small one has 1 hp. You will get 1 score by kill this enemy.
 * Midium one has 5 hp. You will get 2 score by kill this enemy
 * Big one has 7 hp. You will get 3 score by kill this enemy.
 * After some enemy planes is generated, a boss will appear, it has 80 hp. You will get 5 score by kill this enemy.
 * For boss, midium and big enemy plane, they can attack you by shoot. Try to avoid these bullets!
 * Supply will be random generated, you can get a double bullet buff for 15 seconds.
 

 **Explore the game at your own space and see what score you can get!.**
 */




import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'



/*:
 ### Customize your own game
 
 * Now let's add the most important thing, the difficulty of this game - you do not want to try the hardest level of this game at first right?
 
 * Please enter an Int number between 1 - 7
 * 1 is the easiest level and 7 is the hardest level.

 
 * Example:
var difficulty = 5
 
 */
var difficulty = 5


let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 480, height: 640))
let scene = HomeScene(size: CGSize.init(width: 480, height: 640),Mydifficulty:difficulty)
    // Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill
    
    // Present the scene
sceneView.presentScene(scene)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
