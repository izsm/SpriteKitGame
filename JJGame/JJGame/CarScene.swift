//
//  CarScene.swift
//  JJGame
//
//  Created by zhangshumeng on 2022/4/6.
//

import UIKit
import SpriteKit
import GameplayKit

class CarScene: SKScene {

    private var addCarTimer: Timer?
    private var levelTimer: Timer?
    private var pointX1: CGFloat = 0
    private var pointX2: CGFloat = 0
    private var pointX3: CGFloat = 0
    private var isJump: Bool = false
    private var level: Int = 1
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "得分: \(score)"
        }
    }
    private var life: Int = 3 {
        didSet {
            levelLabel.text = "生命x\(life)"
        }
    }
    
    private lazy var bgNode1: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_ track")
        view.position = CGPoint(x: 0, y: 0)
        view.size = CGSize(width: size.width, height: 736/414*size.width)
        view.anchorPoint = CGPoint(x: 0, y: 0)
        view.zPosition = 0
        view.name = "car_ track"
        return view
    }()
    
    private lazy var bgNode2: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_ track")
        view.position = CGPoint(x: 0, y: size.height)
        view.size = size
        view.anchorPoint = CGPoint(x: 0, y: 0)
        view.zPosition = 0
        view.name = "car_ track"
        return view
    }()

    private lazy var backNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "back")
        view.position = CGPoint(x: 30, y: size.height - 30)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.size = CGSize(width: 30, height: 30)
        view.zPosition = 1
        view.name = "back"
        return view
    }()
    
    private lazy var levelLabel: SKLabelNode = {
        let view = SKLabelNode(text: "生命x3")
        view.fontSize = 15
        view.fontColor = .white
        view.position = CGPoint(x: size.width - 15, y: size.height - 30)
        view.zPosition = 1
        view.horizontalAlignmentMode = .right
        return view
    }()
    
    private lazy var scoreLabel: SKLabelNode = {
        let view = SKLabelNode(text: "得分: 0")
        view.fontSize = 15
        view.fontColor = .white
        view.position = CGPoint(x: size.width - 15, y: size.height - 50)
        view.zPosition = 1
        view.horizontalAlignmentMode = .right
        return view
    }()
    
    private lazy var myCarNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_our")
        view.position = CGPoint(x: size.width / 2, y: 260)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 2
        view.name = "car_our"
        return view
    }()
    
    private lazy var leftArrowNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_left_arrow")
        view.position = CGPoint(x: size.width / 6, y: 120)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 2
        view.name = "car_left_arrow"
        return view
    }()
    
    private lazy var jumpNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_jump")
        view.position = CGPoint(x: size.width / 2, y: 120)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 2
        view.name = "car_jump"
        return view
    }()
    
    private lazy var rightArrowNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "car_right_arrow")
        view.position = CGPoint(x: size.width / 6 * 5, y: 120)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 2
        view.name = "car_right_arrow"
        return view
    }()
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .black
        //设置重力加速度
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        pointX1 = size.width / 6
        pointX2 = size.width / 2
        pointX3 = size.width / 6 * 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addChild(bgNode1)
        addChild(bgNode2)
        addChild(backNode)
        addChild(levelLabel)
        addChild(scoreLabel)
        addChild(myCarNode)
        addChild(leftArrowNode)
        addChild(jumpNode)
        addChild(rightArrowNode)
        
        updateMyCarPhysicsBody()
        
        startAddCarTimer()
        startLevelTimer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        let node = atPoint(point)
        let myCarPositionX = myCarNode.position.x
        let isLeft = myCarPositionX == pointX1
        let isCenter = myCarPositionX == pointX2
        let isRight = myCarPositionX == pointX3
        
        switch node.name {
        case "back":
            view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.5))
        case "car_jump":
            guard !isJump else { return }
            isJump = true
            updateMyCarPhysicsBody()
            let scale = SKAction.scale(by: 1.5, duration: 0.2)
            let wait = SKAction.wait(forDuration: 0.5)
            myCarNode.run(SKAction.sequence([scale, wait])) { [weak self] in
                guard let `self` = self else { return }
                self.myCarNode.run(scale.reversed())
                self.isJump = false
                self.updateMyCarPhysicsBody()
            }
        case "car_left_arrow":
            guard !isLeft, !isJump else { return }
            if isCenter  {
                let move = SKAction.moveTo(x: pointX1, duration: 0.15)
                myCarNode.run(move)
            }
            if isRight  {
                let move = SKAction.moveTo(x: pointX2, duration: 0.15)
                myCarNode.run(move)
            }
        case "car_right_arrow":
            guard !isRight, !isJump else { return }
            if isCenter  {
                let move = SKAction.moveTo(x: pointX3, duration: 0.15)
                myCarNode.run(move)
            }
            if isLeft  {
                let move = SKAction.moveTo(x: pointX2, duration: 0.15)
                myCarNode.run(move)
            }
        default:
            break
        }
    }
}

extension CarScene {
    
    private func startAddCarTimer() {
        var ti = 1 - TimeInterval(level - 1) * 0.1
        if ti <= 0.2 {
            ti = 0.2
        }
        addCarTimer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(addCar), userInfo: nil, repeats: true)
    }
    
    private func startLevelTimer() {
        levelTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(levelchange), userInfo: nil, repeats: true)
    }
    
    private func stopAddCarTimer() {
        if let _ = addCarTimer {
            addCarTimer?.invalidate()
            addCarTimer = nil
        }
    }
    
    private func stopLevelTimer() {
        if let _ = levelTimer {
            levelTimer?.invalidate()
            levelTimer = nil
        }
    }
    
    private func updateMyCarPhysicsBody() {
        if isJump {
            myCarNode.physicsBody = nil
        } else {
            myCarNode.physicsBody = SKPhysicsBody(rectangleOf: myCarNode.size)
            //物理体是否受力
            myCarNode.physicsBody?.isDynamic = true
            myCarNode.physicsBody?.allowsRotation = false
            //设置物理体的标识符
            myCarNode.physicsBody?.categoryBitMask = 1
            //设置可与哪一类的物理体发生碰撞
            myCarNode.physicsBody?.contactTestBitMask = 2
            myCarNode.physicsBody?.collisionBitMask = 0
        }
    }
    // 1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2
    // 1.8 2.0 2.2 2.4 2.6 2.8 3.5 4.5 5.5
    @objc private func addCar() {
        let fishIcon = arc4random_uniform(4)
        let enemyNode = SKSpriteNode(imageNamed: "car\(fishIcon)")
        let pointX = [pointX1, pointX2, pointX3].random ?? pointX2
        enemyNode.position = CGPoint(x: pointX, y: size.height + 30)
        enemyNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        enemyNode.zPosition = 1
        enemyNode.name = "otherCar"
        addChild(enemyNode)
        var speed: CGFloat = 0
        switch level {
        case 1, 2, 3, 4, 5, 6:
            speed = 1.8 + CGFloat(level - 1) * 0.2
        default:
            speed = 3.5 + CGFloat(level - 7) * 1
        }
        enemyNode.speed = speed
        let move = SKAction.moveTo(y: -30, duration: 5)
        enemyNode.run(move) { [weak self] in
            guard let `self` = self else { return }
            if self.life > 0 {
                self.score += 1
            }
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
    }
    
    @objc private func levelchange() {
        level += 1
        levelLabel.text = "当前关卡: \(level)"
        stopAddCarTimer()
        startAddCarTimer()
        if level >= 8 {
            stopLevelTimer()
        }
    }
}

extension CarScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        life -= 1
        if life <= 0 {
            life = 0
            stopAddCarTimer()
            stopLevelTimer()
        }
    }
}

extension Array {
    
    /// 从数组中返回一个随机元素
        public var random: Element? {
            //如果数组为空，则返回nil
            guard count > 0 else { return nil }
            let randomIndex = Int(arc4random_uniform(UInt32(count)))
            return self[randomIndex]
        }
}

