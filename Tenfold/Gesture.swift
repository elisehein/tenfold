//
//  Gesture.swift
//  Tenfold
//
//  Created by Elise Hein on 16/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum GestureType {
    case swipeUpAndHold
    case swipeRight
}

// Defaults for .SwipeRight
private struct GestureConfiguration {
    var totalWidth: CGFloat = 186
    var swooshStartDuration: Double = 0.25
    var swooshEndDuration: Double = 0.25
    var swooshStartTimingFunction: String = kCAMediaTimingFunctionEaseIn
    var swooshEndTimingFunction: String = kCAMediaTimingFunctionEaseOut
    var swooshMidPoint: CGFloat = 173
    var fadeInDuration: Double = 0.2
    var fadeOutDuration: Double = 0.25 // Can't be larger than swooshEndDuration
    var disappearanceDelay: Double = 0
}

class Gesture: CAShapeLayer, CAAnimationDelegate {

    static let fingerDiameter: CGFloat = 16
    fileprivate var completionBlock: (() -> Void)?
    fileprivate var config: GestureConfiguration

    var type: GestureType {
        didSet {
            self.config = Gesture.configurationForType(type)
        }
    }

    override init(layer: Any) {
        self.type = .swipeRight
        self.config = Gesture.configurationForType(type)
        super.init(layer: layer)
    }

    init(type: GestureType) {
        self.type = type
        self.config = Gesture.configurationForType(type)
        super.init()
        fillColor = UIColor.white.cgColor
        opacity = 0
    }

    fileprivate class func configurationForType(_ type: GestureType) -> GestureConfiguration {
        switch type {
        case .swipeRight:
            return GestureConfiguration()
        case .swipeUpAndHold:
            return GestureConfiguration(totalWidth: 116,
                                        swooshStartDuration: 0.5,
                                        swooshEndDuration: 0,
                                        swooshStartTimingFunction: kCAMediaTimingFunctionLinear,
                                        swooshEndTimingFunction: kCAMediaTimingFunctionEaseOut,
                                        swooshMidPoint: 116,
                                        fadeInDuration: 0.2,
                                        fadeOutDuration: 0.15,
                                        disappearanceDelay: 0.65)
        }
    }

    override func display() {
        super.display()
        path = circlePath()
    }

    func totalWidth() -> CGFloat {
        return config.totalWidth
    }

    func perform(withDelay delay: Double = 0, completion: (() -> Void)? = nil) {
        completionBlock = completion

        switch type {
        case .swipeUpAndHold:
            faceUp()
            beginSwoosh(withDelay: delay)
        case .swipeRight:
            beginSwoosh(withDelay: delay)
        }
    }

    fileprivate func faceUp() {
        anchorPoint = CGPoint(x: 0, y: 0)
        transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-M_PI_2), 0.0, 0.0, 1.0)
    }

    fileprivate func beginSwoosh(withDelay delay: Double) {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.beginTime = CACurrentMediaTime() + delay
        opacityAnimation.duration = config.fadeInDuration
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.isRemovedOnCompletion = false
        add(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = config.swooshStartDuration
        animation.fromValue = circlePath()
        animation.toValue = pathWhileSwooshing()
        animation.timingFunction = CAMediaTimingFunction(name: config.swooshStartTimingFunction)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        add(animation, forKey: "swooshStart")
    }

    fileprivate func endSwoosh() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = config.fadeOutDuration
        opacityAnimation.beginTime = CACurrentMediaTime() +
                                     config.swooshEndDuration -
                                     config.fadeOutDuration +
                                     config.disappearanceDelay
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.isRemovedOnCompletion = false
        add(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = config.swooshEndDuration
        animation.fromValue = pathWhileSwooshing()
        animation.toValue = circlePath(atX: config.totalWidth - Gesture.fingerDiameter)
        animation.timingFunction = CAMediaTimingFunction(name: config.swooshEndTimingFunction)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        add(animation, forKey: "swooshEnd")
    }

    fileprivate func pathWhileSwooshing() -> CGPath {
        let furthestX = config.swooshMidPoint - (Gesture.fingerDiameter / 2)

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 8))

        bezierPath.addCurve(to: CGPoint(x: furthestX - 4, y: 0),
                                   controlPoint1: CGPoint(x: 0, y: 3.58),
                                   controlPoint2: CGPoint(x: furthestX - 8.42, y: 0))
        bezierPath.addCurve(to: CGPoint(x: furthestX, y: 8),
                                   controlPoint1: CGPoint(x: furthestX + 0.42, y: 0),
                                   controlPoint2: CGPoint(x: furthestX, y: 3.58))
        bezierPath.addCurve(to: CGPoint(x: furthestX - 4, y: 16),
                                   controlPoint1: CGPoint(x: furthestX, y: 12.42),
                                   controlPoint2: CGPoint(x: furthestX + 0.42, y: 16))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 8),
                                   controlPoint1: CGPoint(x: furthestX - 8.42, y: 16),
                                   controlPoint2: CGPoint(x: 0, y: 12.42))

        return bezierPath.cgPath
    }

    // swiftlint:disable:next variable_name
    fileprivate func circlePath(atX x: CGFloat = 0) -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: x, y: 8))

        bezierPath.addCurve(to: CGPoint(x: x + 8, y: 0),
                                   controlPoint1: CGPoint(x: x, y: 3.58),
                                   controlPoint2: CGPoint(x: x + 3.58, y: 0))
        bezierPath.addCurve(to: CGPoint(x: x + 16, y: 8),
                                   controlPoint1: CGPoint(x: x + 12.42, y: 0),
                                   controlPoint2: CGPoint(x: x + 16, y: 3.58))
        bezierPath.addCurve(to: CGPoint(x: x + 8, y: 16),
                                   controlPoint1: CGPoint(x: x + 16, y: 12.42),
                                   controlPoint2: CGPoint(x: x + 12.42, y: 16))
        bezierPath.addCurve(to: CGPoint(x: x, y: 8),
                                   controlPoint1: CGPoint(x: x + 3.58, y: 16),
                                   controlPoint2: CGPoint(x: x, y: 12.42))

        return bezierPath.cgPath
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == animation(forKey: "swooshStart") {
            endSwoosh()
        } else {
            completionBlock?()
            completionBlock = nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
