//
//  PinballScene.swift
//  JJGame
//
//  Created by zhangshumeng on 2022/4/11.
//

import UIKit
import SpriteKit
import GameplayKit

struct PinballModel {
    var reward: Int = 0
    var rewardText: String = ""
    var rewardArea: CGRect = .zero
}

class PinballScene: SKScene {
    
    private var topOffset: CGFloat = 50
    private var isTouch: Bool = false
    private var gridWidth: CGFloat = 0
    // 开始触摸弹簧的位置
    private var startTouchPoint: CGPoint = .zero
    // 弹簧的偏移量
    private var offsetY: CGFloat = 0
    private var rewards = [PinballModel]()
    private var reward: Int = 200 {
        didSet {
            oreLabel.text = "矿石: \(reward)"
        }
    }
    
    private lazy var backNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "back")
        view.position = CGPoint(x: 30, y: size.height-30)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.size = CGSize(width: 30, height: 30)
        view.zPosition = 1
        view.name = "back"
        return view
    }()
    
    private lazy var oreLabel: SKLabelNode = {
        let view = SKLabelNode(text: "矿石: 200")
        view.fontSize = 15
        view.fontColor = .white
        view.position = CGPoint(x: size.width-15, y: size.height-30)
        view.zPosition = 1
        view.horizontalAlignmentMode = .right
        return view
    }()
    
    private lazy var springNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "tanhuang")
        view.position = CGPoint(x: gridWidth*8.5+3.5, y: size.height-size.width-topOffset)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 2
        view.size = CGSize(width: 28, height: 120)
        view.name = "tanhuang"
        return view
    }()
    
    private lazy var ballNode: SKSpriteNode = {
        let view = SKSpriteNode(imageNamed: "boliqiu")
        view.position = CGPoint(x: gridWidth*8.5+3.5, y: size.height-size.width+74-topOffset)
        view.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.zPosition = 3
        view.size = CGSize(width: 28, height: 28)
        view.name = "boliqiu"
        view.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        //设置物理体的标识符
        view.physicsBody?.categoryBitMask = 2
        //设置可与哪一类的物理体发生碰撞
        view.physicsBody?.contactTestBitMask = 1
        return view
    }()
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .darkGray
        //设置重力加速度
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gridWidth = size.width / 9
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        createRewardData()
        setupPhysicsBody()
        createNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouch = false
        offsetY = 0
        physicsWorld.gravity = .zero
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        let node = atPoint(point)
        switch node.name {
        case "back":
            view?.presentScene(MenuScene(size: size), transition: .fade(withDuration: 0.5))
        case "tanhuang" where reward >= 50:
            isTouch = true
            startTouchPoint = point
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        if isTouch {
            offsetY = point.y-startTouchPoint.y
            if offsetY >= -80, offsetY <= 0 {
                springNode.size = CGSize(width: 28, height: 120+offsetY)
                ballNode.position = CGPoint(x: gridWidth * 8.5+3.5, y: size.height-size.width+74-topOffset+offsetY/2)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTouch {
            springNode.size = CGSize(width: 28, height: 120)
            physicsWorld.gravity = CGVector(dx: 0, dy: -3.5)
            let dy = 300 * -(offsetY/2) * 0.1
            ballNode.physicsBody?.applyForce(CGVector(dx: 0, dy: dy))
            offsetY = 0
            view?.isUserInteractionEnabled = false
            reward -= 50
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        springNode.size = CGSize(width: 28, height: 120)
        offsetY = 0
    }
}

extension PinballScene {
    
    private func createRewardData() {
        let reward = [100, 80, 60, 50, 40, 30, 20, 10]
        for (i, v) in reward.enumerated() {
            var model = PinballModel()
            model.reward = v
            model.rewardText = "\(v)\n矿石"
            model.rewardArea = CGRect(x: CGFloat(i) * gridWidth, y: size.height-size.width-topOffset, width: gridWidth, height: 28)
            rewards.append(model)
        }
    }
    
    private func createNode() {
        addChild(backNode)
        addChild(oreLabel)
        addChild(springNode)
        addChild(ballNode)
        
        let backgroundNode = SKSpriteNode(imageNamed: "pinball_bg")
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height-size.width/2-topOffset)
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundNode.zPosition = 0
        backgroundNode.size = CGSize(width: size.width, height: size.width)
        backgroundNode.name = "backgroundNode"
        addChild(backgroundNode)
        
        let ovalNode = SKSpriteNode(imageNamed: "pinball_oval")
        ovalNode.position = CGPoint(x: size.width/2, y: size.height-15-topOffset)
        ovalNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ovalNode.zPosition = 2
        ovalNode.size = CGSize(width: 20, height: 20)
        ovalNode.name = "oval"
        addChild(ovalNode)
        ovalNode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ovalNode.physicsBody?.affectedByGravity = false
        ovalNode.physicsBody?.collisionBitMask = 0
        
        let tipsNode = SKLabelNode(text: "50矿石玩一次")
        if #available(iOS 11.0, *) {
            tipsNode.numberOfLines = 0
        }
        tipsNode.position = CGPoint(x: size.width/2, y: size.height-size.width*0.5-topOffset)
        tipsNode.zPosition = 2
        tipsNode.fontSize = 25
        tipsNode.fontColor = .white
        tipsNode.name = "tips"
        addChild(tipsNode)
        
        // 创建隔板
        for (i, model) in rewards.enumerated() {
            let gebanNode = SKSpriteNode(imageNamed: i<rewards.count-1 ? "pinball_geban1" : "pinball_geban2")
            gebanNode.position = CGPoint(x: gridWidth*CGFloat(i+1), y: size.height-size.width+(i<rewards.count-1 ? 110 : 180)/2-topOffset)
            gebanNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            gebanNode.zPosition = 2
            gebanNode.size = CGSize(width: 8, height: i<rewards.count-1 ? 110 : 180)
            gebanNode.name = "geban"
            addChild(gebanNode)
            gebanNode.physicsBody = SKPhysicsBody(rectangleOf: gebanNode.size)
            gebanNode.physicsBody?.affectedByGravity = false
            gebanNode.physicsBody?.collisionBitMask = 0
            
            let rewardNode = SKLabelNode(text: model.rewardText)
            if #available(iOS 11.0, *) {
                rewardNode.numberOfLines = 0
            }
            rewardNode.position = CGPoint(x: gridWidth*CGFloat(i)+gridWidth/2, y: size.height-size.width+30-topOffset)
            rewardNode.zPosition = 2
            rewardNode.fontSize = 18
            rewardNode.fontColor = .white
            rewardNode.name = model.rewardText
            addChild(rewardNode)
        }
    }
    
    private func setupPhysicsBody() {
        let path = UIBezierPath()
        path.lineWidth = 2
        path.move(to: CGPoint(x: 0, y: size.height-size.width-topOffset))
        path.addLine(to: CGPoint(x: 0, y: size.height-size.width/2-topOffset))
        path.addArc(withCenter: CGPoint(x: size.width/2, y: size.height-size.width/2-topOffset), radius: size.width/2, startAngle: -.pi, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: size.width, y: size.height-size.width/2-topOffset))
        path.addLine(to: CGPoint(x: size.width, y: size.height-size.width-topOffset))
        path.close()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
    }
}

extension PinballScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 弹簧所在的区域
        let springArea = CGRect(x: CGFloat(8)*gridWidth, y: size.height-size.width-topOffset, width: gridWidth, height: 28)
        if springArea.contains(ballNode.position) {
            view?.isUserInteractionEnabled = true
            return
        }
        if let v = view, v.isUserInteractionEnabled {
            return
        }
        for model in rewards {
            if model.rewardArea.contains(ballNode.position) {
                reward += model.reward
                view?.isUserInteractionEnabled = true
            }
        }
    }
}
