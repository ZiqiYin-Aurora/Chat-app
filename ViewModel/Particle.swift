//
//  Particle.swift
//  Chatting
//
//  Created by Yin Celia on 2021/12/2.
//

import Foundation
import SwiftUI
import UIKit

protocol ParticleAnimationable {

}

extension ParticleAnimationable where Self: UIViewController {

    func startParticleAnimation(_ point : CGPoint) {
        // 1.创建发射器
        let emitter = CAEmitterLayer()
        
        // 2.设置发射器的位置
        //emitter.emitterPosition = point
        emitter.emitterPosition = self.view.center
        
        // 3.开启三维效果
        emitter.preservesDepth = true
        
        // 4.创建例子, 并且设置例子相关的属性
        var cells = [CAEmitterCell]()
        for i in 1..<5 {
            // 4.1.创建例子Cell
            let cell = CAEmitterCell()
            
            // 4.2.设置粒子速度
            cell.velocity = 30
            cell.velocityRange = 300
            
            // 4.3.设置例子的大小
            cell.scale = 2.04
            cell.scaleRange = 0.3
            cell.scaleSpeed = -0.15
            cell.alphaRange = 0.75
            cell.alphaSpeed = -0.07
            
            // 4.4.设置粒子方向
            cell.emissionLongitude = .pi * -0.5
            cell.emissionRange = .pi * 0.5
            
            // 4.5.设置例子的存活时间
            cell.lifetime = 25
            cell.lifetimeRange = 20
            
            // 4.6.设置粒子旋转
            cell.spin = CGFloat(Double.pi/2)
            cell.spinRange = CGFloat(Double.pi/2 / 2)
            
            cell.yAcceleration = 30.0
            cell.xAcceleration = 10.0
            
            // 4.6.设置例子每秒弹出的个数
            cell.birthRate = 20
            
            // 4.7.设置粒子展示的图片
            cell.contents = UIImage(named: "snow\(i)")?.cgImage
            //.contents = UIButton.init(type: .custom)
            //cell.contents.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            
            // 4.8.添加到数组中
            cells.append(cell)
        }
        
        // 5.将粒子设置到发射器中
        emitter.emitterCells = cells
        
        // 6.将发射器的layer添加到父layer中
        view.layer.addSublayer(emitter)
        
        //按钮点击事件
        func tapped(sender: UIButton) {
                print(sender.tag)
        }
    }
    
    func stopParticleAnimation() {
        view.layer.sublayers?.filter({ $0.isKind(of: CAEmitterLayer.self)}).first?.removeFromSuperlayer()
    }
}
