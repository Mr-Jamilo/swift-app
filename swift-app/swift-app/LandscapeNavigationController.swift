//
//  LandscapeNavigationController.swift
//  swift-app
//
//  Created by Jamie Lo on 22/02/2026.
//

import UIKit

class LandscapeNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.topViewController?.supportedInterfaceOrientations ?? .all
    }

    override var shouldAutorotate: Bool {
        return self.topViewController?.shouldAutorotate ?? true
    }
}
