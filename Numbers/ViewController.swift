//
//  ViewController.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let titleLabel = UILabel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        titleLabel.text = "Numbers"
        titleLabel.font = UIFont(name: "Lucida Sans Unicode", size: 20)
        titleLabel.textColor = UIColor.themeColor(.OffBlack)
        titleLabel.frame = CGRectMake(0, 0, 100, 100)
        
        view.addSubview(titleLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.themeColor(.OffWhite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

