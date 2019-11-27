//
//  GameScene.swift
//  Space
//
//  Created by L703 on 2015. 11. 10..
//  Copyright (c) 2015년 L703. All rights reserved.
//

import SpriteKit // 아이폰에 내장된 2D게임 엔진

class GameScene: SKScene, SKPhysicsContactDelegate {
                 // 게임상의 캐릭터나 배경 등 노드를 얹을 수 있다.
                          // 두 물체가 접촉 했을 때 처리를 하게 만드는 것.
    var Player : SKSpriteNode = SKSpriteNode() // 컬러 와 질감 이미지 , 색 사각형 을 그리는 것
    var lastYieldTimeInterval : NSTimeInterval = NSTimeInterval() // 시간 간격
    var lastUpdateTimeInterval : NSTimeInterval = NSTimeInterval()
    var aliensDestroyed:Int = 0
    
    let alienCategory:UInt32 = 0x1 << 1
                      // 정수 없는 32비트 정수형 타입.
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)*/
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    override init(size:CGSize){
                       // 크기를 나타내는 구조
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        Player = SKSpriteNode(imageNamed: "shuttle")
        Player.position = CGPointMake(self.frame.size.width/2, Player.size.height/2+20)
        
        self.addChild(Player)
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        // 물리 환경을 무중력 상태로 만듬.
        self.physicsWorld.contactDelegate = self
        // 접촉 판정 처리를 하는 객체를 자기 자신으로 지정.
        // SKScene 서브 클래스는 위의 physicsWorld.contactDelegate 따라야 함.
    }

    required init?(coder aDecoder: NSCoder) { // IB 상에 이 클래스를 추가했을 때는 이 메소드를 통해서 인스턴스가 만들어짐
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    func addAlien(){ // 우주선
        var alien:SKSpriteNode = SKSpriteNode(imageNamed: "alien")
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
              // 노드의 물체를 만들어 준다.
              // 이 속성값이 정의 되어 있지 않으면 충돌이나 중력의 영향, 접촉 판정을 할 수 없다.
        alien.physicsBody?.dynamic = true
              // 물리연산의 적용을 받을 것 인지 결정.
        alien.physicsBody?.categoryBitMask = alienCategory
                           // 충돌이나 중력,접촉 전기장의 영향 등 선별할 수 있는 마스크 값.
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
                           // 각각 자신과 상호작용 할 수 있는 물체들의 마스크를 정의
                           // 예를 들어 우주선과 플레이어는 충돌 할 수 있지만 우주선끼리는 충돌하지 않는다 던지 하는걸 구현 할 때 씁니다.
                           // physicsBody 는 옵셔널 속성이기 때문에 ?를 붙여야합니다.
        
        let minX = alien.size.width/2
        let maxX = self.frame.size.width - alien.size.width/2
        let rangeX = maxX - minX
        let position:CGFloat = CGFloat(Int(arc4random_uniform(UInt32(UInt(rangeX))))) + minX
        
        alien.position = CGPointMake(position, self.frame.size.height+alien.size.height)
                         // CGPoint를 만들어내는 함수
        self.addChild(alien)
             // Scene 이나 노드에 하위 노드를 붙임.
        
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = Int(arc4random()) % Int(rangeDuration) + Int(minDuration)
        
        var actionArray:NSMutableArray = NSMutableArray()
                        // Foundation의 가변 배열
                        // 그냥 var array = [...] 하고 바로 쓰면 된답니다.
        
        actionArray.addObject(SKAction.moveTo(CGPointMake(position, -alien.size.height), duration: NSTimeInterval(duration)))
                              // 노드가 움직이거나 사라지게 하는 등 액션을 나타나게 함.
        actionArray.addObject((SKAction.runBlock({
            var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
                           // 장면 전환에 사용
            var gameOverScene:SKScene = GameOverScene(size: self.size, won: false)
            self.view!.presentScene(gameOverScene, transition: transition)
        })))
        
        actionArray.addObject(SKAction.removeFromParent())
        
        alien.runAction(SKAction.sequence(actionArray as [AnyObject]))
              // 만들어 놓은 액션 객체가 노드에 적용되도록 결합. 액션은 노드가 Scene 에 추가 되었을 때 만 동작.
        
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate:CFTimeInterval){
        lastYieldTimeInterval += timeSinceLastUpdate
        if (lastYieldTimeInterval > 1){
            lastYieldTimeInterval = 0
            self.addAlien()
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    override func update(currentTime: CFTimeInterval) {
        var timeSinceLastUpdate = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        if (timeSinceLastUpdate > 1){
            timeSinceLastUpdate = 1/60
            lastUpdateTimeInterval = currentTime
        }
        
        self.updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }

    //------------------------------------------------------------------------------------------------------------------------------------
    
    override func touchesEnded(touches:Set<NSObject>, withEvent event: UIEvent) {
        self.runAction(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
                                                   // 우주선을 맞출때 공격하는 소리
        var touch = touches.first as? UITouch
        var location:CGPoint = touch!.locationInNode(self)
        
        var torpedo:SKSpriteNode = SKSpriteNode(imageNamed: "torpedo")
                                                            // 공격할 때 이미지
        torpedo.position = Player.position
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width/2)
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        var offset:CGPoint = vecSub(location, b: torpedo.position)
        
        if (offset.y < 0){
            return
        }
        
        self.addChild(torpedo)
        
        var direction:CGPoint = vecNormalize(offset)
        var shotLength:CGPoint = vecMult(direction, b:1000)
        var finalDestination:CGPoint = vecAdd(shotLength, b: torpedo.position)
        let velocity = 568/1
        let moveDuration:Float = Float(self.size.width) / Float(velocity)
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration)))
        actionArray.addObject(SKAction.removeFromParent())
        
        torpedo.runAction(SKAction.sequence(actionArray as [AnyObject]))
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    func didBeginContact(contact: SKPhysicsContact) {
                                  // 접촉 판정이 일어나면 Delegate 에게 이 객체가 전달.
                                  // 이 객체는 충돌한 두 물체의 physicsBody 와 접촉이 일어난 좌표, 츙돌시 충격량을 저장하고 있음.
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        torpedoDidCollideWithAlien(contact.bodyA.node as! SKSpriteNode, alien: contact.bodyB.node as! SKSpriteNode)
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    func torpedoDidCollideWithAlien(torpedo:SKSpriteNode, alien:SKSpriteNode){ // 우주선을 맞췄을 때
        println("HIT!")
        torpedo.removeFromParent()
        alien.removeFromParent()
        aliensDestroyed++
        
        if (aliensDestroyed > 30){
            var transition:SKTransition = SKTransition.flipHorizontalWithDuration(0.5)
                           // Scene 전환에 대한 정보를 담는 객체
            var gameOverScene:SKScene = GameOverScene(size: self.size, won: true)
            self.view!.presentScene(gameOverScene, transition: transition)
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------
    
    func vecAdd(a:CGPoint, b:CGPoint) ->CGPoint {
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint) ->CGPoint {
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMult(a:CGPoint, b:CGFloat) ->CGPoint{
        return CGPointMake(a.x * b, a.y * b)
    }
    
    func vecLength(a:CGPoint) ->CGFloat {
        return CGFloat(sqrtf(CFloat(a.x)*CFloat(a.x)+CFloat(a.y)*CFloat(a.y)))
    }
    
    func vecNormalize(a:CGPoint) ->CGPoint {
        var length:CGFloat = vecLength(a)
        return CGPointMake(a.x / length, a.y / length)
    }
   
}
