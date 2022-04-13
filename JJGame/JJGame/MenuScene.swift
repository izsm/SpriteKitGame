//
//  MenuScene.swift
//  JJGame
//
//  Created by zhangshumeng on 2022/3/29.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuScene: SKScene {

    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // 飞机大战
        let planNode = SKSpriteNode(imageNamed: "plan_icon")
        planNode.color = .white
        planNode.position = CGPoint(x: size.width / 2 - 70, y: size.height / 2)
        planNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        planNode.size = CGSize(width: 100, height: 100)
        planNode.zPosition = 1
        planNode.name = "plan"
        addChild(planNode)
        
        // 弹球
        let pinballScene = SKSpriteNode(imageNamed: "pinball_icon")
        pinballScene.color = .white
        pinballScene.position = CGPoint(x: size.width / 2 + 70, y: size.height / 2)
        pinballScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pinballScene.size = CGSize(width: 100, height: 100)
        pinballScene.zPosition = 1
        pinballScene.name = "pinball"
        addChild(pinballScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = (touches as NSSet).anyObject() as? UITouch else { return }
        let point = touch.location(in: self)
        let node = atPoint(point)
        
        switch node.name {
        case "plan":
            let scene = PlanScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: .doorway(withDuration: 0.5))
        case "pinball":
            let scene = PinballScene(size: size)
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: .doorway(withDuration: 0.5))
        default:
            break
        }
    }
}
