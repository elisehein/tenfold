//
//  ModalOverlay.swift
//  Tenfold
//
//  Created by Elise Hein on 03/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class ModalOverlay: UIViewController {

    let modal = UIView()

    static let modalButtonHeight: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 60
    }()

    init() {
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext

        view.backgroundColor = UIColor.themeColor(.OffBlack).colorWithAlphaComponent(0.65)

        modal.backgroundColor = UIColor.themeColor(.OffWhite)
        modal.layer.shadowColor = UIColor.themeColor(.OffBlack).CGColor
        modal.layer.shadowOffset = CGSize(width: 2, height: 2)
        modal.layer.shadowRadius = 2
        modal.layer.shadowOpacity = 0.5

        view.addSubview(modal)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        if touches.count == 1 {
            let touch = touches.first
            if let point = touch?.locationInView(view) {
                if !CGRectContainsPoint(modal.frame, point) {
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    class func configureModalButton(button: UIButton, color: UIColor) {
        button.setBackgroundImage(UIImage.imageWithColor(color), forState: .Normal)
        button.setBackgroundImage(UIImage.imageWithColor(color.darken()), forState: .Highlighted)

        button.layer.borderColor = UIColor.themeColor(.OffWhite).CGColor
        button.layer.borderWidth = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
