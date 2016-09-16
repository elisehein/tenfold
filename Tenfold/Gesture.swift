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

class Gesture: CAShapeLayer {

    static let totalWidth: CGFloat = 220
    static let totalHeight: CGFloat = 20

    private var type: GestureType = .SwipeRight
    private var completionBlock: (() -> Void)?

    override init(layer: AnyObject) {
        super.init(layer: layer)
    }

    init(type: GestureType) {
        self.type = type
        super.init()
        fillColor = UIColor.whiteColor().CGColor
        opacity = 0
    }

    override func display() {
        super.display()
        path = circlePath()
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
        opacityAnimation.duration = 0.2
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = false
        addAnimation(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = type == .SwipeRight ? 0.2 : 0.3
        animation.fromValue = circlePath()
        animation.toValue = pathWhileSwooshing()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.delegate = self
        addAnimation(animation, forKey: "swooshStart")
    }

    private func endSwoosh() {
        let movementDuration = type == .SwipeRight ? 0.2 : 0.2
        let fadeOutDuration = 0.2

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = type == .SwipeRight ? fadeOutDuration : 0.15
        opacityAnimation.beginTime = CACurrentMediaTime() +
                                     (type == .SwipeRight ?
                                      movementDuration - fadeOutDuration :
                                      movementDuration + 0.5)
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.fillMode = kCAFillModeForwards
        opacityAnimation.removedOnCompletion = false
        addAnimation(opacityAnimation, forKey: nil)

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = movementDuration
        animation.fromValue = pathWhileSwooshing()
        animation.toValue = endPath()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.delegate = self
        addAnimation(animation, forKey: "swooshEnd")
    }

    private func pathWhileSwooshing() -> CGPath {
        let furthestX: CGFloat = type == .SwipeRight ? 150 : 80

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

    private func endPath() -> CGPath {
        return circlePath(atX: type == .SwipeRight ? 200 : 100)
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
