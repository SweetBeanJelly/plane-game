//
//  GameOverScene.swift
//  Space
//
//  Created by L703 on 2015. 11. 17..
//  Copyright (c) 2015년 L703. All rights reserved.
//

import UIKit
import SpriteKit

// 이기거나 졌을때 화면이 뜨는 창 입니다.

class GameOverScene: SKScene {
   
    init(size:CGSize, won:Bool){
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        var message:NSString = NSString()
        
        if(won){
            message = "YOU WIN!"
        }else{
            message = "GAME OVER"
        }
        
        var label:SKLabelNode = SKLabelNode(fontNamed: "Chalkboard")
        label.text = message as String
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        self.addChild(label)
        self.runAction(SKAction.sequence([SKAction.waitForDuration(3.0),SKAction.runBlock({
            var transtion:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
            var scene:SKScene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transtion)
            })
        ]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
