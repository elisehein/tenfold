//
//  ViewController.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit
import PureLayout

class ViewController: UIViewController {
    
    let titleLabel = UILabel()
    var hasLoadedConstraints = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        titleLabel.text = "Numbers"
        titleLabel.font = UIFont.themeFontWithSize(20)
        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        
        view.addSubview(titleLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.themeColor(.OffWhite)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if (!hasLoadedConstraints) {
            titleLabel.autoCenterInSuperview()
            hasLoadedConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

