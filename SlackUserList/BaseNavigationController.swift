//
//  BaseNavigationController.swift
//  SlackUserList
//
//  Created by Rajath Bhagavathi on 7/27/17.
//  Copyright © 2017 ArrayFounder. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    
    var viewCornerRadius: CGFloat = 5.0 {
        didSet {
            view.layer.cornerRadius = viewCornerRadius
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = viewCornerRadius
        view.layer.masksToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard viewControllers.count > 0 else { return .default }
        return viewControllers[viewControllers.count - 1].preferredStatusBarStyle
    }
}
