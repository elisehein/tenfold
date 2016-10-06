//
//  ModalOverlay.swift
//  Tenfold
//
//  Created by Elise Hein on 03/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

enum ModalPosition {
    case Center
    case Bottom
}

class ModalOverlay: UIViewController {

    static let horizontalInset: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 30
    }()

    static let contentPadding: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 70 : 40
    }()

    static let titleTextSpacing: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 25 : 15
    }()

    let modal = UIView()
    let position: ModalPosition

    static let modalButtonHeight: CGFloat = {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 80 : 60
    }()

    init(position: ModalPosition) {
        self.position = position
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

    override func updateViewConstraints() {
        switch position {
        case .Center:
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                modal.autoSetDimension(.Width, toSize: 460)
            } else {
                modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
                modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 8)
            }

            modal.autoCenterInSuperview()

        case .Bottom:
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                modal.autoSetDimension(.Width, toSize: 460)
                modal.autoCenterInSuperview()
            } else {
                modal.autoPinEdgeToSuperviewEdge(.Left, withInset: 8)
                modal.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 8)
                modal.autoPinEdgeToSuperviewEdge(.Right, withInset: 8)
            }
        }

        super.updateViewConstraints()
    }

    class func configureModalButton(button: UIButton, color: UIColor, shouldHighlight: Bool = true) {
        button.setBackgroundImage(UIImage.imageWithColor(color), forState: .Normal)

        if shouldHighlight {
            button.setBackgroundImage(UIImage.imageWithColor(color.darken()), forState: .Highlighted)
        } else {
            button.setBackgroundImage(UIImage.imageWithColor(color), forState: .Highlighted)
        }

        button.layer.borderColor = UIColor.themeColor(.OffWhite).CGColor
        button.layer.borderWidth = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
