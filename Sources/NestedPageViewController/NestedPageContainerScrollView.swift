//
//  NestedPageContainerScrollView.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/8/18.
//  Copyright © 2025 SPStore. All rights reserved.
//

import UIKit
import QuartzCore

class NestedPageContainerScrollView: UIScrollView {
    
    weak var headerContentView: UIView?
    
    /**
    重写这个方法有2个作用：
    1、禁止手指在pageHeaderContainerView上横向滑动containerScrollView（主要作用）。
    2、解决一个奇怪的bug：场景：假如一共有3个tab，在第2个tab下，使劲下拉contentScrollView，未等contentScrollView回弹结束就立即切换tab到第3页，然后再滑回第2页时（稍微用点力），最终会滑向第1页，这个现象可能的解释如下：
    当在第2页下拉未等回弹结束就快速切换到第3页时，系统内部可能有一个"惯性计算器"仍在运行，记录着下拉的速度和方向。当开始从第3页滑向第2页时，这个"惯性计算器"可能错误地将先前的下拉惯性与新的左滑动作结合，导致系统认为滑动的距离或速度比实际更大，从而跳过了第2页直接到第1页。
    */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        panGestureRecognizer.isEnabled = true

        guard let headerContentView = headerContentView else {
            return super.hitTest(point, with: event)
        }
        
        let convertedPoint = convert(point, to: headerContentView)
        if headerContentView.bounds.contains(convertedPoint) {
            panGestureRecognizer.isEnabled = false
        }
        return super.hitTest(point, with: event)
    }
}


