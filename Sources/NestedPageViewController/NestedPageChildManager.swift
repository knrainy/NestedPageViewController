//
//  NestedPageChildManager.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/8/22.
//  Copyright © 2025 SPStore. All rights reserved.
//

import UIKit

/// 嵌套页面子控制器管理器，负责管理子控制器的创建、加载和生命周期管理
class NestedPageChildManager {
        
    weak var viewController: NestedPageViewController?
    weak var headerManager: NestedPageHeaderManager?
    weak var scrollCoordinator: NestedPageScrollCoordinator?
    
    /// 当前显示的子控制器索引
    var currentIndex: Int = 0
    
    var viewControllerMap: [Int: UIViewController & NestedPageScrollable] = [:]
    
    var currentContentScrollView: UIScrollView?

    var contentScrollViewY: CGFloat {
        if let currentContentScrollView {
            let contentScrollViewY = currentContentScrollView.convert(currentContentScrollView.bounds, to: viewController?.containerView).minY
            return contentScrollViewY
        }
        return 0.0
    }
        
    init(viewController: NestedPageViewController?, headerManager: NestedPageHeaderManager) {
        self.viewController = viewController
        self.headerManager = headerManager
    }
    
    // MARK: - ViewController Management
    
    func viewController(at index: Int) -> (UIViewController & NestedPageScrollable)? {
        return viewControllerMap[index]
    }
    
    func loadViewController(at index: Int) {
        guard let viewController = viewController,
              let dataSource = viewController.dataSource,
              let headerManager = headerManager,
              let scrollCoordinator = scrollCoordinator,
              index >= 0 && index < dataSource.numberOfViewControllers(in: viewController) else {
            return
        }
        
        var childViewController = self.viewController(at: index)
        if childViewController == nil {
            childViewController = dataSource.pageViewController(viewController, viewControllerAt: index)
            guard let childViewController = childViewController else { return }
            
            viewController.addChild(childViewController)
            childViewController.view.frame = CGRect(x: CGFloat(index) * viewController.view.bounds.width, y: 0, width: viewController.containerScrollView.bounds.width, height: viewController.containerScrollView.bounds.height)
            childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewController.containerScrollView.addSubview(childViewController.view)
            childViewController.didMove(toParent: viewController)
            
            // 保证先走viewDidLoad，再获取contentScrollView，contentScrollView可能在viewDidLoad中才初始化
            let contentScrollView = childViewController.contentScrollView()
            scrollCoordinator.observeScrollView(contentScrollView)
            contentScrollView.contentInsetAdjustmentBehavior = .never
            contentScrollView.showsVerticalScrollIndicator = viewController.showsVerticalScrollIndicator
            contentScrollView.showsHorizontalScrollIndicator = false
            contentScrollView.bounces = viewController.bounces
            headerManager.createAndAddPageHeader(at: index, contentScrollView: contentScrollView)
            
            viewControllerMap[index] = childViewController

            childViewController.view.setNeedsLayout()
            childViewController.view.layoutIfNeeded()
            
            contentScrollView.contentInset = UIEdgeInsets(top: headerManager.pageHeaderHeight, left: 0, bottom: contentScrollView.contentInset.bottom, right: 0)
            contentScrollView.scrollIndicatorInsets = contentScrollView.contentInset
            
            let currentContentInitializeContentOffsetY = -contentScrollView.contentInset.top + min(-headerManager.previousPinY + contentScrollView.frame.minY, headerManager.coverHeight - viewController.stickyOffset)
            contentScrollView.setContentOffset(CGPoint(x: 0, y: currentContentInitializeContentOffsetY), animated: false)
        }
    }
    
    func loadViewControllers(at indexes: [Int]) {
        guard !indexes.isEmpty else { return }
        
        for index in indexes {
            loadViewController(at: index)
        }
    }
    
    func loadViewControllers() {
        guard let viewController = viewController else { return }
        
        // 初始化 currentIndex
        currentIndex = viewController.preloadViewControllerIndexes.first ?? 0
        
        // 预加载视图控制器
        if !viewController.preloadViewControllerIndexes.isEmpty {
            loadViewControllers(at: viewController.preloadViewControllerIndexes)
        }
        
        // 确保首次进入页面时currentContentScrollView有值
        if let childViewController = self.viewController(at: currentIndex) {
            currentContentScrollView = childViewController.contentScrollView()
        }
    }
    
    // MARK: - Layout Update
    
    func updateChildrenLayouts() {
        guard let viewController = viewController,
              let headerManager = headerManager else { return }
        
        let viewWidth = viewController.containerScrollView.bounds.width
        let viewHeight = viewController.containerScrollView.bounds.height
        
        // 遍历所有已加载的视图控制器，重置其scrollView
        for (index, childViewController) in viewControllerMap {
            childViewController.view.frame = CGRect(x: CGFloat(index) * viewWidth, y: 0, width: viewWidth, height: viewHeight)
            // 重置子视图控制器的视图状态
            childViewController.view.setNeedsLayout()
            childViewController.view.layoutIfNeeded()
            
            let contentScrollView = childViewController.contentScrollView()
            // 更新contentInset
            let inset = UIEdgeInsets(top: headerManager.pageHeaderHeight, left: 0, bottom: contentScrollView.contentInset.bottom, right: 0)
            contentScrollView.contentInset = inset
            contentScrollView.scrollIndicatorInsets = inset
            
            // 重置contentOffset到初始位置（顶部）
            contentScrollView.setContentOffset(CGPoint(x: 0, y: -headerManager.pageHeaderHeight), animated: false)
        }
    }
    
    // MARK: - Reload
    
    func reloadPages() {
        
        // 保存当前索引
        let currentIdx = currentIndex
        
        // 获取已加载的视图控制器索引
        let loadedIndexes = Array(viewControllerMap.keys)
        
        // 清理视图控制器
        for childViewController in viewControllerMap.values {
            childViewController.removeFromParent()
            childViewController.view.removeFromSuperview()
        }
        viewControllerMap.removeAll()
        
        // 重新加载之前加载过的视图控制器
        loadViewControllers(at: loadedIndexes)
        
        // 恢复当前索引
        currentIndex = currentIdx
        if let childViewController = self.viewController(at: currentIdx) {
            currentContentScrollView = childViewController.contentScrollView()
        }
    }
    
    // MARK: - Cleanup
    
    func cleanupOldData() {
        currentContentScrollView = nil
        for childViewController in viewControllerMap.values {
            // 使用Combine不需要显式移除观察者
            // 当scrollView被释放时，相关的订阅会自动失效
            childViewController.removeFromParent()
            childViewController.view.removeFromSuperview()
        }
        viewControllerMap.removeAll()
    }
}
