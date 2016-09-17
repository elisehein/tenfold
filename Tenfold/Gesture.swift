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
    case SwipeUpAndHold
    case SwipeRight
}

// Defaults for .SwipeRight
private struct GestureConfiguration {
    var totalWidth: CGFloat = 216
    var swooshStartDuration: Double = 0.25
    var swooshEndDuration: Double = 0.25
    var swooshStartTimingFunction: String = kCAMediaTimingFunctionEaseIn
    var swooshEndTimingFunction: String = kCAMediaTimingFunctionEaseOut
    var swooshMidPoint: CGFloat = 158
    var fadeInDuration: Double = 0.2
    var fadeOutDuration: Double = 0.2
    var disappearanceDelay: Double = 0
}

class Gesture: CAShapeLayer {

    static let fingerDiameter: CGFloat = 16
    private var completionBlock: (() -> Void)?
    private var config: GestureConfiguration

    var type: GestureType {
        didSet {
            self.config = Gesture.configurationForType(type)
        }
    }

    override init(layer: AnyObject) {
        self.type = .SwipeRight
        self.config = Gesture.configurationForType(type)
        super.init(layer: layer)
    }

    init(type: GestureType) {
        self.type = type
        self.config = Gesture.configurationForType(type)
        super.init()
        fillColor = UIColor.whiteColor().CGColor
        opacity = 0
    }

    private class func configurationForType(type: GestureType) -> GestureConfiguration {
        switch type {
        case .SwipeRight:
            return GestureConfiguration()
        case .SwipeUpAndHold:
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
        case .SwipeUpAndHold:
            faceUp()
            beginSwoosh(withDelay: delay)
        case .SwipeRight:
            beginSwoosh(withDelay: delay)
        }
    }

    private func faceUp() {
        anchorPoint = CGPoint(x: 0, y: 0)
        transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-M_PI_2), 0.0, 0.0, 1.0)
    }

    private func beginSwoosh(withDelay delay: Double) {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.beginTime = CACurrentMediaTime() + delay
        opacityAnimation.duration = config.fadeInDuration
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = false
        addAnimation(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = config.swooshStartDuration
        animation.fromValue = circlePath()
        animation.toValue = pathWhileSwooshing()
        animation.timingFunction = CAMediaTimingFunction(name: config.swooshStartTimingFunction)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.delegate = self
        addAnimation(animation, forKey: "swooshStart")
    }

    private func endSwoosh() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = config.fadeOutDuration
        opacityAnimation.beginTime = CACurrentMediaTime() +
                                     config.swooshEndDuration -
                                     config.fadeOutDuration +
                                     config.disappearanceDelay
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = false
        addAnimation(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = config.swooshEndDuration
        animation.fromValue = pathWhileSwooshing()
        animation.toValue = circlePath(atX: config.totalWidth - Gesture.fingerDiameter)
        animation.timingFunction = CAMediaTimingFunction(name: config.swooshEndTimingFunction)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.delegate = self
        addAnimation(animation, forKey: "swooshEnd")
    }

    private func pathWhileSwooshing() -> CGPath {
        let furthestX = config.swooshMidPoint - (Gesture.fingerDiameter / 2)

        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0, y: 8))

        bezierPath.addCurveToPoint(CGPoint(x: furthestX - 4, y: 0),
                                   controlPoint1: CGPoint(x: 0, y: 3.58),
                                   controlPoint2: CGPoint(x: furthestX - 8.42, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: furthestX, y: 8),
                                   controlPoint1: CGPoint(x: furthestX + 0.42, y: 0),
                                   controlPoint2: CGPoint(x: furthestX, y: 3.58))
        bezierPath.addCurveToPoint(CGPoint(x: furthestX - 4, y: 16),
                                   controlPoint1: CGPoint(x: furthestX, y: 12.42),
                                   controlPoint2: CGPoint(x: furthestX + 0.42, y: 16))
        bezierPath.addCurveToPoint(CGPoint(x: 0, y: 8),
                                   controlPoint1: CGPoint(x: furthestX - 8.42, y: 16),
                                   controlPoint2: CGPoint(x: 0, y: 12.42))

        return bezierPath.CGPath
    }

    // swiftlint:disable:next variable_name
    private func circlePath(atX x: CGFloat = 0) -> CGPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: x, y: 8))

        bezierPath.addCurveToPoint(CGPoint(x: x + 8, y: 0),
                                   controlPoint1: CGPoint(x: x, y: 3.58),
                                   controlPoint2: CGPoint(x: x + 3.58, y: 0))
        bezierPath.addCurveToPoint(CGPoint(x: x + 16, y: 8),
                                   controlPoint1: CGPoint(x: x + 12.42, y: 0),
                                   controlPoint2: CGPoint(x: x + 16, y: 3.58))
        bezierPath.addCurveToPoint(CGPoint(x: x + 8, y: 16),
                                   controlPoint1: CGPoint(x: x + 16, y: 12.42),
                                   controlPoint2: CGPoint(x: x + 12.42, y: 16))
        bezierPath.addCurveToPoint(CGPoint(x: x, y: 8),
                                   controlPoint1: CGPoint(x: x + 3.58, y: 16),
                                   controlPoint2: CGPoint(x: x, y: 12.42))

        return bezierPath.CGPath
    }

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim == animationForKey("swooshStart") {
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
