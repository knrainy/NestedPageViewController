//
//  UIScrollView+ScrollingHelper.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2023/8/19.
//  Copyright © 2023 SPStore. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    /// 检测垂直方向是否在回弹状态
    var isVerticalBouncing: Bool {
        return isTopBouncing || isBottomBouncing
    }
    
    /// 检测是否在顶部回弹状态
    var isTopBouncing: Bool {
        let minOffsetY = -adjustedContentInset.top
        return contentOffset.y < minOffsetY
    }
    
    /// 检测是否在底部回弹状态
    var isBottomBouncing: Bool {
        let maxOffsetY = contentSize.height - bounds.height + adjustedContentInset.bottom
        return contentOffset.y > maxOffsetY
    }
    
    /// 停止滚动
    func stopScrolling() {
        if #available(iOS 17.4, *) {
            stopScrollingAndZooming()
        } else {
            setContentOffset(contentOffset, animated: false)
        }
    }
    
    func scrollToTop(animated: Bool = true) {
        let topOffset = -adjustedContentInset.top
        setContentOffset(CGPoint(x: 0, y: topOffset), animated: animated)
    }

}


