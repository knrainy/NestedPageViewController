//
//  NavigationController.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/1.
//

import UIKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        // 全局禁用全屏返回，恢复系统边缘返回
        fd_fullscreenPopGestureRecognizer.isEnabled = false
        interactivePopGestureRecognizer?.isEnabled = true
        
        // FullScreenGestureViewController启用全屏返回
        if viewController is FullScreenGestureViewController {
            fd_fullscreenPopGestureRecognizer.isEnabled = true
            interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1 {
            return false
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
