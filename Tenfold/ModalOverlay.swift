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
    case center
    case bottom
}

class ModalOverlay: UIViewController {

    static let horizontalInset: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 30
    }()

    static let contentPadding: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 70 : 40
    }()

    static let titleTextSpacing: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 25 : 15
    }()

    let modal = UIView()
    let position: ModalPosition

    static let modalButtonHeight: CGFloat = {
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60
    }()

    init(position: ModalPosition) {
        self.position = position
        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext

        view.backgroundColor = UIColor.themeColor(.offBlack).withAlphaComponent(0.65)

        modal.backgroundColor = UIColor.themeColor(.offWhite)
        modal.layer.shadowColor = UIColor.themeColor(.offBlack).cgColor
        modal.layer.shadowOffset = CGSize(width: 2, height: 2)
        modal.layer.shadowRadius = 2
        modal.layer.shadowOpacity = 0.5

        view.addSubview(modal)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if touches.count == 1 {
            let touch = touches.first
            if let point = touch?.location(in: view) {
                if !modal.frame.contains(point) {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    override func updateViewConstraints() {
        switch position {
        case .center:
            if UIDevice.current.userInterfaceIdiom == .pad {
                modal.autoSetDimension(.width, toSize: 460)
            } else {
                modal.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
                modal.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
            }

            modal.autoCenterInSuperview()

        case .bottom:
            if UIDevice.current.userInterfaceIdiom == .pad {
                modal.autoSetDimension(.width, toSize: 460)
                modal.autoCenterInSuperview()
            } else {
                modal.autoPinEdge(toSuperviewEdge: .left, withInset: 8)
                modal.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
                modal.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
            }
        }

        super.updateViewConstraints()
    }

    class func configureModalButton(_ button: UIButton, color: UIColor, shouldHighlight: Bool = true) {
        button.setBackgroundImage(UIImage.imageWithColor(color), for: UIControlState())

        if shouldHighlight {
            button.setBackgroundImage(UIImage.imageWithColor(color.darken()), for: .highlighted)
        } else {
            button.setBackgroundImage(UIImage.imageWithColor(color), for: .highlighted)
        }

        button.layer.borderColor = UIColor.themeColor(.offWhite).cgColor
        button.layer.borderWidth = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
