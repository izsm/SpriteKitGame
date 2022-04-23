//
//  GoFishScene.swift
//  JJGame
//
//  Created by zhangshumeng on 2022/4/6.
//

import UIKit
import SpriteKit
import GameplayKit

class GoFishScene: SKScene {
    
    // 创建鱼定时器
    private var addFishTimer: Timer?
    
    private lazy var bgNode1: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "fish_bg")
        view.position = CGPoint(x: 0, y: 0)
        view.size = size
        view.anchorPoint = CGPoint(x: 0, y: 0)
        view.zPosition = 0
        view.name = "fish_bg"
        return view
    }()
    
//    private lazy var bgNode2: SKSpriteNode = {
//        let view = SKSpriteNode(imageNamed: "fish_bg")
//        view.position = CGPoint(x: 0, y: size.height)
//        view.size = size
//        view.anchorPoint = CGPoint(x: 0, y: 0)
//        view.zPosition = 0
//        view.name = "fish_bg"
//        return view
//    }()

    private lazy var backNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "back")
        view.position = CGPoint(x: 30, y: size.height - 30)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.size = CGSize(width: 30, height: 30)
        view.zPosition = 1
        view.name = "back"
        return view
    }()
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .black
        //设置重力加速度
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(bgNode1)
//        addChild(bgNode2)
        addChild(backNode)
        
        
        addFishTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addFish), userInfo: nil, repeats: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        let node = atPoint(point)
        switch node.name {
        case "back":
            view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.5))
        default:
            break
        }
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        super.update(currentTime)
//
//        backgroudScrollUpdate()
//    }
//
//    // 让背景动起来
//    private func backgroudScrollUpdate() {
//        bgNode1.position = CGPoint(x: bgNode1.position.x, y: bgNode1.position.y - 4)
//        bgNode2.position = CGPoint(x: bgNode2.position.x, y: bgNode2.position.y - 4)
//        if bgNode1.position.y <= -size.height {
//            bgNode1.position = CGPoint(x: 0, y: 0)
//            bgNode2.position = CGPoint(x: 0, y: size.height)
//        }
//    }
}

extension GoFishScene {
    
    @objc private func addFish() {
        let fishIcon = arc4random_uniform(4)
        let enemyNode = SKSpriteNode(imageNamed: "fish\(fishIcon)")
        let pointX = CGFloat(arc4random_uniform(UInt32(size.width/2+30)))
        enemyNode.position = CGPoint(x: pointX + 20, y: -30)
        enemyNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        enemyNode.size = CGSize(width: 40, height: 40)
        enemyNode.zPosition = 1
        enemyNode.name = "fish"
        addChild(enemyNode)
        
        let ti = TimeInterval(arc4random_uniform(5))
        enemyNode.run(SKAction.moveTo(y: size.height + 30, duration: 10 + ti)) {
            enemyNode.removeAllActions()
            enemyNode.removeFromParent()
        }
        
        enemyNode.physicsBody = SKPhysicsBody(rectangleOf: enemyNode.size)
        //物理体是否受力
        enemyNode.physicsBody?.isDynamic = true
        enemyNode.physicsBody?.allowsRotation = false
        //设置物理体的标识符
        enemyNode.physicsBody?.categoryBitMask = 2
        //设置可与哪一类的物理体发生碰撞
        enemyNode.physicsBody?.contactTestBitMask = 1
        enemyNode.physicsBody?.collisionBitMask = 0
//        enemyNode.physicsBody?.mass = CGFloat(enemyLife)
    }
}

extension GoFishScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
//        var fishHookNode: SKSpriteNode?
//        var fishNode: SKSpriteNode?
//        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2 {
//            fishHookNode = contact.bodyA.node as? SKSpriteNode
//            fishNode = contact.bodyB.node as? SKSpriteNode
//        } else {
//            fishHookNode = contact.bodyB.node as? SKSpriteNode
//            fishNode = contact.bodyA.node as? SKSpriteNode
//        }
//        guard let fishHookNode = fishHookNode, let fishNode = fishNode else { return }
        
    }
}
