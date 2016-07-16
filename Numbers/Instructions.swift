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

    init () {
        super.init(nibName: nil, bundle: nil)
        title = "Instructions"
        view.backgroundColor = UIColor.grayColor()
    }

    override func viewWillAppear (animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    required init? (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
