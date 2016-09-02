//
//  Onboarding.swift
//  Tenfold
//
//  Created by Elise Hein on 02/09/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Onboarding: Play {
    init() {
        super.init(shouldLaunchOnboarding: false, isOnboarding: true)

        modalTransitionStyle = .CrossDissolve
        menu.onDismissOnboarding = handleDismissal
    }

    private func handleDismissal() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
