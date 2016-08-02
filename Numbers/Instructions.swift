//
//  Instructions.swift
//  Numbers
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Instructions: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "How to play"
        view.backgroundColor = UIColor.themeColor(.OffWhite)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)


        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true

        navigationController?.navigationBar.tintColor = UIColor.themeColor(.OffBlack)
        let navigationTitleFont = UIFont.themeFontWithSize(14, weight: .Bold    )
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: navigationTitleFont]

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        button.setBackgroundImage(UIImage(named: "back-arrow"), forState: .Normal)
        button.addTarget(self,
                         action: #selector(Instructions.goBack),
                         forControlEvents: .TouchUpInside)
        let backButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = backButton
    }

    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
