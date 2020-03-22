//
//  PulsingCircleAnimation.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

final class PulsingCircleAnimation: Animation {
    private var animationLayers: [CALayer] = []
    private var animationKey: String {
        String(describing: Self.self)
    }
    private let defaultAnimationSize = CGSize(width: 40.0, height: 40.0)
    private let defaultFill = UIColor.white.cgColor
    
    // MARK: - Animation -
    func add(on layer: CALayer) {
        let beginTimes = [0, 0.5, 1]
        let animationGroup = self.animationGroup
        for i in 0...2 {
            let circle = self.circle
            animationGroup.beginTime = beginTimes[i]
            circle.add(animationGroup, forKey: animationKey)
            circle.frame = CGRect(x: (layer.frame.size.width - defaultAnimationSize.width) / 2,
                                  y: (layer.frame.size.height - defaultAnimationSize.height) / 2,
                                  width: defaultAnimationSize.width,
                                  height: defaultAnimationSize.height)
            layer.addSublayer(circle)
            animationLayers.append(circle)
        }
    }
    
    func removeFromSuperlayer() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    // MARK: - Private -
    private var animationGroup: CAAnimationGroup {
        let defaultSettings = AnimationSettings(
            range: Range(from: 0, to: 1),
            duration: 1,
            repeatCount: .infinity,
            removedOnCompletion: false
        )
        let defaultGroupSettings = AnimationGroupSettings(
            duration: 1,
            repeatCount: .infinity
        )
        
        let scaleAnimation = makeBasicAnimation(with: defaultSettings, and: .scale)
        let opacityAnimation = makeBasicAnimation(with: defaultSettings.rangeInverted, and: .opacity)
        
        let group = makeAnimationGroup(from: [scaleAnimation, opacityAnimation], with: defaultGroupSettings)
        
        return group
    }
    
    private var circle: CAShapeLayer {
        let circle = CAShapeLayer()
        let circlePath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0,
                                width: defaultAnimationSize.width,
                                height: defaultAnimationSize.height),
            cornerRadius: defaultAnimationSize.width / 2
        )
        circle.path = circlePath.cgPath
        circle.fillColor = defaultFill
        circle.opacity = 0
        
        return circle
    }
    
    private func makeBasicAnimation(with settings: AnimationSettings, and keyPath: AnimationKeyPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath.rawValue)
        animation.fromValue = settings.range.from
        animation.toValue = settings.range.to
        animation.duration = settings.duration
        animation.repeatCount = settings.repeatCount
        animation.isRemovedOnCompletion = settings.removedOnCompletion
        return animation
    }
    
    private func makeAnimationGroup(from animations: [CAAnimation], with settings: AnimationGroupSettings) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.duration = settings.duration
        group.repeatCount = settings.repeatCount
        group.animations = animations
        return group
    }
}
