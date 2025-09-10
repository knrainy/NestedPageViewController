//
//  ChildBaseViewController.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/8/31.
//

import UIKit

/// 刷新类型枚举
enum RefreshType {
    /// 无刷新
    case none
    /// 局部刷新
    case partial
    /// 全局刷新
    case global
}

class ChildBaseViewController: UIViewController {
    
    /// 刷新类型，默认为局部刷新
    var refreshType: RefreshType = .none
    
    var ignoredScrollViewContentInsetTop: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
