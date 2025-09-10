//
//  NestedPageHeaderView.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/8/19.
//  Copyright © 2025 SPStore. All rights reserved.
//

import UIKit

class NestedPageHeaderView: UIView {
    
    /// 当为 true 时，容器本身不会拦截事件，但子视图仍可正常响应
    var allowsSubviewHitTestOnly: Bool = false
    
    /// 标记当前手指触摸点，是否在pageHeader上
    var isHitted: Bool = false
    
    // 头视图既能穿透滑动scrollView，又能与子控件产生交互事件，原因是：
    // 1、能穿透滑动scrollView是因为header的父视图为scrollView，
    // 2、能与子控件产生交互事件是因为重写了'hitTest:withEvent:'
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        isHitted = false

        // 禁用、隐藏、透明时直接忽略
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else {
            return nil
        }
        
        // 如果开启「仅子视图命中」
        if allowsSubviewHitTestOnly {
            return hitTestInSubviews(point: point, event: event)
        }
        
        if self.point(inside: point, with: event) {
            isHitted = true
            return super.hitTest(point, with: event)
        }
        
        return hitTestInSubviews(point: point, event: event)
    }
    
    // 抽离的重复代码：在子视图中查找命中的视图
    private func hitTestInSubviews(point: CGPoint, event: UIEvent?) -> UIView? {
        for subview in subviews {
            guard subview.isUserInteractionEnabled, !subview.isHidden, subview.alpha > 0.01 else {
                continue
            }
            
            let convertedPoint = convert(point, to: subview)
            guard subview.point(inside: convertedPoint, with: event) else {
                continue
            }
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                isHitted = true
                return hitView
            }
        }
        isHitted = false
        return nil
    }
}



