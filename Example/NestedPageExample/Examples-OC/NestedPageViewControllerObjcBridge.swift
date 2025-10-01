//
//  NestedPageViewControllerObjcBridge.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/5.
//

import UIKit
import NestedPageViewController

// MARK: - 嵌套页面视图控制器的数据源协议桥接

@objc public protocol NestedPageViewControllerDataSourceObjc: AnyObject {
    @objc func numberOfViewControllers(in pageViewController: NestedPageViewControllerObjcBridge) -> Int
    @objc func pageViewController(_ pageViewController: NestedPageViewControllerObjcBridge, viewControllerAt index: Int) -> NestedPageScrollable?
    @objc func coverView(in pageViewController: NestedPageViewControllerObjcBridge) -> UIView?
    @objc func heightForCoverView(in pageViewController: NestedPageViewControllerObjcBridge) -> CGFloat
    @objc func tabStrip(in pageViewController: NestedPageViewControllerObjcBridge) -> UIView?
    @objc optional func heightForTabStrip(in pageViewController: NestedPageViewControllerObjcBridge) -> CGFloat
    @objc optional func titlesForTabStrip(in pageViewController: NestedPageViewControllerObjcBridge) -> [String]?
}

// MARK: - 嵌套页面视图控制器的代理协议桥接

@objc public protocol NestedPageViewControllerDelegateObjc: AnyObject {
    @objc optional func pageViewController(_ pageViewController: NestedPageViewControllerObjcBridge, didScrollToPageAt index: Int)
    @objc optional func pageViewController(_ pageViewController: NestedPageViewControllerObjcBridge, contentScrollViewDidScroll scrollView: UIScrollView, headerOffset: CGFloat, isSticked: Bool)
}


// MARK: - 嵌套页面视图控制器桥接

@objcMembers
public class NestedPageViewControllerObjcBridge: NSObject {
    public let nestedPageViewController: NestedPageViewController
    
    // MARK: - Properties
    
    public var view: UIView {
        return nestedPageViewController.view
    }
    
    public var containerScrollView: UIScrollView {
        return nestedPageViewController.containerScrollView
    }
    
    public var currentIndex: Int {
        return nestedPageViewController.currentIndex
    }
    
    public var keepsContentScrollPosition: Bool {
        get { return nestedPageViewController.keepsContentScrollPosition }
        set { nestedPageViewController.keepsContentScrollPosition = newValue }
    }
    
    public var headerBounces: Bool {
        get { return nestedPageViewController.headerBounces }
        set { nestedPageViewController.headerBounces = newValue }
    }
    
    public var headerAlwaysFixed: Bool {
        get { return nestedPageViewController.headerAlwaysFixed }
        set { nestedPageViewController.headerAlwaysFixed = newValue }
    }
    
    public var headerHeight: CGFloat {
        return nestedPageViewController.headerHeight
    }
    
    public var stickyOffset: CGFloat {
        get { return nestedPageViewController.stickyOffset }
        set { nestedPageViewController.stickyOffset = newValue }
    }
    
    public var isSticked: Bool {
        return nestedPageViewController.isSticked
    }
    
    public var showsVerticalScrollIndicator: Bool {
        get { return nestedPageViewController.showsVerticalScrollIndicator }
        set { nestedPageViewController.showsVerticalScrollIndicator = newValue }
    }
    
    public var bounces: Bool {
        get { return nestedPageViewController.bounces }
        set { nestedPageViewController.bounces = newValue }
    }
    
    public var automaticallyAdjustsContainerInsets: Bool {
        get { return nestedPageViewController.automaticallyAdjustsContainerInsets }
        set { nestedPageViewController.automaticallyAdjustsContainerInsets = newValue }
    }
    
    public var containerInsets: UIEdgeInsets {
        get { return nestedPageViewController.containerInsets }
        set { nestedPageViewController.containerInsets = newValue }
    }
    
    public var allowsSwipeToChangePage: Bool {
        get { return nestedPageViewController.allowsSwipeToChangePage }
        set { nestedPageViewController.allowsSwipeToChangePage = newValue }
    }
    
    public var defaultPageIndex: Int {
        get {
            return nestedPageViewController.defaultPageIndex
        }
        set { 
            nestedPageViewController.defaultPageIndex = newValue
        }
    }
    
    public var headerMovesOnlyWhenTouchingHeaderDuringHover: Bool {
        get { return nestedPageViewController.headerMovesOnlyWhenTouchingHeaderDuringHover }
        set { nestedPageViewController.headerMovesOnlyWhenTouchingHeaderDuringHover = newValue }
    }
    
    public var interruptsScrollingWhenTransitioningToFullStick: Bool {
        get { return nestedPageViewController.interruptsScrollingWhenTransitioningToFullStick }
        set { nestedPageViewController.interruptsScrollingWhenTransitioningToFullStick = newValue }
    }
    
    public weak var dataSource: NestedPageViewControllerDataSourceObjc? {
        didSet {
            nestedPageViewController.dataSource = self
        }
    }
    
    public weak var delegate: NestedPageViewControllerDelegateObjc? {
        didSet {
            nestedPageViewController.delegate = self
        }
    }
    
    // MARK: - Initialization
    
    public override init() {
        self.nestedPageViewController = NestedPageViewController()
        super.init()
        nestedPageViewController.dataSource = self
        nestedPageViewController.delegate = self
    }
    
    // MARK: - Public Methods
    
    public func addToParentViewController(_ parentViewController: UIViewController) {
        parentViewController.addChild(nestedPageViewController)
        parentViewController.view.addSubview(nestedPageViewController.view)
        nestedPageViewController.didMove(toParent: parentViewController)
    }
    
    public func scrollToPage(at index: Int, animated: Bool) {
        nestedPageViewController.scrollToPage(at: index, animated: animated)
    }
    
    public func scrollToTop(animated: Bool = true) {
        nestedPageViewController.scrollToTop(animated: animated)
    }
    
    public func viewController(at index: Int) -> UIViewController? {
        return nestedPageViewController.viewController(at: index)
    }
    
    public func rebuild() {
        nestedPageViewController.rebuild()
    }
    
    public func reloadPages() {
        nestedPageViewController.rebuildPages()
    }
    
    public func loadViewController(at index: Int) {
        nestedPageViewController.loadViewController(at: index)
    }
    
    public func unloadViewController(at index: Int) {
        nestedPageViewController.unloadViewController(at: index)
    }
    
    public func updateLayouts() {
        nestedPageViewController.updateLayouts()
    }
}

// MARK: - NestedPageViewControllerDataSource 实现

extension NestedPageViewControllerObjcBridge: NestedPageViewControllerDataSource {
    public func numberOfViewControllers(in pageViewController: NestedPageViewController) -> Int {
        return dataSource?.numberOfViewControllers(in: self) ?? 0
    }
    
    public func pageViewController(_ pageViewController: NestedPageViewController, viewControllerAt index: Int) -> NestedPageScrollable? {
        guard let viewController = dataSource?.pageViewController(self, viewControllerAt: index) else {
            return nil
        }
        return viewController
    }
    
    public func coverView(in pageViewController: NestedPageViewController) -> UIView? {
        return dataSource?.coverView(in: self)
    }
    
    public func heightForCoverView(in pageViewController: NestedPageViewController) -> CGFloat {
        return dataSource?.heightForCoverView(in: self) ?? 0
    }
    
    public func tabStrip(in pageViewController: NestedPageViewController) -> UIView? {
        return dataSource?.tabStrip(in: self)
    }
    
    public func heightForTabStrip(in pageViewController: NestedPageViewController) -> CGFloat {
        return dataSource?.heightForTabStrip?(in: self) ?? 50.0
    }
    
    public func titlesForTabStrip(in pageViewController: NestedPageViewController) -> [String]? {
        return dataSource?.titlesForTabStrip?(in: self)
    }
}

// MARK: - NestedPageViewControllerDelegate 实现

extension NestedPageViewControllerObjcBridge: NestedPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: NestedPageViewController, didScrollToPageAt index: Int) {
        delegate?.pageViewController?(self, didScrollToPageAt: index)
    }
    
    public func pageViewController(_ pageViewController: NestedPageViewController,
                                   contentScrollViewDidScroll scrollView: UIScrollView,
                                   headerOffset:CGFloat,
                                   isSticked: Bool) {
        delegate?.pageViewController?(self, contentScrollViewDidScroll: scrollView, headerOffset:headerOffset, isSticked: isSticked)
    }
}
