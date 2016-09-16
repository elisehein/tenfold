//
//  GestureIllustration.swift
//  Tenfold
//
//  Created by Elise Hein on 16/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class GestureIllustration: UIImageView {
    init() {
        super.init(frame: CGRect.zero)

        contentMode = .Center
        image = UIImage(named: "swipe")
    }

    func animate(startX startX: CGFloat = 0,
                         startY: CGFloat = 0,
                         startRotation: Double = 0,
                         endX: CGFloat = 0,
                         endY: CGFloat = 0,
                         endRotation: Double = 0,
                         duration: Double = 0.6,
                         appearanceDelay: Double = 0,
                         disappearanceDelay: Double = 0,
                         completion: (() -> Void)) {

        // Note for Swift 3:
        // http://stackoverflow.com/a/39302719/2026098
        var t = CGAffineTransformIdentity
        t = CGAffineTransformRotate(t, self.rads(startRotation))
        t = CGAffineTransformTranslate(t, startX, startY)
        transform = t
        UIView.animateWithDuration(0.1,
                                   delay: appearanceDelay,
                                   options: [],
                                   animations: { self.alpha = 1 },
                                   completion: nil)

        UIView.animateWithDuration(duration,
                                   delay: appearanceDelay + 0.1,
                                   options: .CurveEaseOut,
                                   animations: {
            t = CGAffineTransformIdentity
            t = CGAffineTransformRotate(t, self.rads(endRotation))
            t = CGAffineTransformTranslate(t, endX, endY)
            self.transform = t
        }, completion: { _ in
            UIView.animateWithDuration(0.15,
                                       delay: disappearanceDelay,
                                       options: [],
                                       animations: {
                    self.alpha = 0
            }, completion: nil)

            completion()
        })
    }

    private func rads(degrees: Double) -> CGFloat {
        return CGFloat(M_PI * (degrees) / 180)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
