//
//  AppDelegate.swift
//  Numbers
//
//  Created by Elise Hein on 09/02/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootViewController: UIViewController?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        application.applicationSupportsShakeToEdit = true

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        if let window = window {
            window.backgroundColor = UIColor.clearColor()
            window.rootViewController = Play()
            window.makeKeyAndVisible()
        }

        return true
    }
}
