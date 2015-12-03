//
//  UIApplicationExtension.swift
//  twitzer
//
//  Created by abdullah cengiz on 02/12/15.
//  Copyright © 2015 abdullah cengiz. All rights reserved.
//

import UIKit
import Foundation

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
