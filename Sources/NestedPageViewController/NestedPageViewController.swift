//
//  NestedPageViewController.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/8/22.
//  Copyright © 2025 SPStore. All rights reserved.
//

import UIKit
import Combine

/// 嵌套页面滚动协议，所有需要嵌套在NestedPageViewController中的子控制器必须实现该协议
/// 该协议用于获取子控制器中的滚动视图，以便实现联动效果
@objc public protocol NestedPageScrollable: AnyObject {
    
    /// 获取子控制器中的内容滚动视图
    /// - Returns: 返回用于滚动内容的UIScrollView对象，contentScrollView必须要有布局.
    /// - Note: 该方法用于获取子控制器中的滚动视图，以便与容器视图进行联动
    func contentScrollView() -> UIScrollView
}

/// 嵌套页面视图控制器的数据源协议
/// 该协议定义了获取嵌套页面结构所需的所有数据方法
public protocol NestedPageViewControllerDataSource: AnyObject {
    
    /// 获取页面控制器中子控制器的数量
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回子控制器的数量
    func numberOfViewControllers(in pageViewController: NestedPageViewController) -> Int
    
    /// 获取指定索引位置的子控制器（内置缓存，每个索引只调用一次）
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Parameter index: 子控制器的索引
    /// - Returns: 返回实现了NestedPageScrollable协议的视图控制器
    func pageViewController(_ pageViewController: NestedPageViewController, viewControllerAt index: Int) -> (UIViewController & NestedPageScrollable)?
    
    /// 获取顶部封面视图
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回顶部封面视图对象，如果不需要可返回nil
    /// - Note: 在NestedPageViewController的生命周期之内，只调用一次，除非reloadData.
    func coverView(in pageViewController: NestedPageViewController) -> UIView?
    
    /// 获取顶部封面视图的高度
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回顶部封面视图的高度
    func heightForCoverView(in pageViewController: NestedPageViewController) -> CGFloat
    
    /// 获取标签栏视图（可以通过简单配置，直接使用内置的NestedPageTabStripView，如果需要更多定制化的样式，请自定义标签栏视图或者使用其它开源组件）
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回标签栏视图对象，如果不需要可返回nil
    /// - Note: 在NestedPageViewController的生命周期之内，只调用一次，除非reloadData.
    func tabStrip(in pageViewController: NestedPageViewController) -> UIView?
    
    /// 获取标签栏的高度
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回标签栏的高度
    func heightForTabStrip(in pageViewController: NestedPageViewController) -> CGFloat
    
    /// 获取标签栏视图的标题数组（内置标签栏视图，优先级低于'tabStripInPageViewController:'）
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Returns: 返回标签栏视图的标题数组，如果不需要可返回nil
    func titlesForTabStrip(in pageViewController: NestedPageViewController) -> [String]?
}

/// 嵌套页面视图控制器的代理协议
/// 该协议定义了页面控制器的事件回调方法
public protocol NestedPageViewControllerDelegate: AnyObject {
    
    /// 页面横向滚动到指定索引位置的回调方法
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Parameter index: 当前显示的页面索引
    /// - Note: 当用户滚动或以其他方式切换到新页面时会调用此方法
    func pageViewController(_ pageViewController: NestedPageViewController, didScrollToPageAt index: Int)

    /// 内容垂直滚动视图的滚动状态变化回调方法
    /// - Parameter pageViewController: 嵌套页面视图容器控制器
    /// - Parameter scrollView: 当前正在滚动的内容视图
    /// - Parameter headerOffset: 头部相对contentScrollView顶部的偏移量
    /// - Parameter isSticked: 是否处于完全吸顶状态
    /// - Note: 当内容视图滚动状态发生变化时会调用此方法，可用于控制导航栏等UI元素的显示/隐藏
    func pageViewController(_ pageViewController: NestedPageViewController, contentScrollViewDidScroll scrollView: UIScrollView, headerOffset: CGFloat, isSticked: Bool)
}

/// 整体结构为：顶部封面视图 + 标签栏 + 子页面区域，支持整体联动滚动
open class NestedPageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    /// 横向滚动的容器视图
    public private(set) var containerScrollView: UIScrollView = NestedPageContainerScrollView()
    
    /// 当前显示的子控制器索引
    public var currentIndex: Int {
        return childManager.currentIndex
    }
    
    /// 是否保持子列表的滚动位置
    /// 当设置为true时，非吸顶状态下切换子列表时会保持每个列表的滚动位置
    /// 当设置为false时，非吸顶状态下切换子列表时会将新的列表滚动到初始位置
    public var keepsContentScrollPosition: Bool = false
    
    /// 控制scrollView滑动到顶部后继续下拉头部视图是否有弹性效果（也就是继续下拉scrollView，头部视图是否跟随下拉）
    /// 如果想要实现局部下拉刷新，请将该属性设置为false，才能看到刷新动效。
    public var headerBounces: Bool = true
    
    /// 头视图是否始终保持不动
    public var headerAlwaysFixed: Bool = false
    
    /// 头部总高度
    public var headerHeight: CGFloat {
        return headerManager.pageHeaderHeight
    }
    
    /// 头视图达到吸顶状态的偏移，最小值为0，最大值为coverHeight
    public var stickyOffset: CGFloat = 0.0
    
    /// 是否已经吸顶了
    public var isSticked: Bool {
        return scrollCoordinator.isSticked
    }

    /// 垂直滚动条是否显示
    public var showsVerticalScrollIndicator: Bool = false
    
    /// 整个页面是否有弹性效果
    public var bounces: Bool = true
    
    /// 是否自动调整容器视图的顶部和底部内边距
    /// 使用场景：系统导航栏显示情况下，如果nestedPageViewController.view的frame是全屏的，此时滑到屏幕最顶端header才会吸顶
    /// 但我们可能希望到达安全区域边界时就开始吸顶，此时可以设置automaticallyAdjustsContainerInsets=true，等效于containerInsets = UIEdgeInsets(safeTop, 0, safeBottom, 0)
    /// 如果不希望设置bottom，可以自行设置containerInsets
    public var automaticallyAdjustsContainerInsets: Bool = false
    
    /// 容器视图的内边距，如果同时设置了containerInsets和automaticallyAdjustsContainerInsets = true，会取二者的较大值，只有top和bottom有效。
    /// automaticallyAdjustsContainerInsets=true会同时调整top和botttom，containerInsets可以自由控制
    public var containerInsets: UIEdgeInsets = .zero

    /// 是否允许通过手指拖拽来切换页面
    public var allowsSwipeToChangePage: Bool = true {
        didSet {
            updateScrollEnabled()
        }
    }
    
    /// 预加载指定的控制器索引数组，数组中的第一个索引将被优先展示.
    /// 可以通过该属性，设置默认加载的子列表，比如初始状态下就要加载第3个子列表，那么设置[3]即可，相当于间接的设置了currentIndex.
    public var preloadViewControllerIndexes: [Int] = [0]
    
    /// 当头部悬停在中间位置时，向上滚动是否只有触摸头部才让头部移动（keepsContentScrollPosition == true时才见效）
    /// 当为 true 时：
    ///   - 头部悬空时，触摸头部区域向上滚动 → 头部跟随移动
    ///   - 头部悬空时，触摸内容区域向上滚动 → 头部保持不动
    /// 当为 false 时：
    ///   - 头部悬空时，无论触摸哪里向上滚动 → 头部都跟随移动（默认行为）
    /// 悬空定义：当keepsContentScrollPosition设置为true，在其中某一个tab下滑动contentScrollView直到完全吸顶，切换tab
    /// 然后滑动contentScrollView直到未吸顶，再切回原来的tab，此时定义头部为悬空（半吸顶）。
    public var headerMovesOnlyWhenTouchingHeaderDuringHover: Bool = false
    
    /// 过渡到完全吸顶时是否中断惯性滚动
    /// 当为 true 时：从未完全吸顶过渡到完全吸顶时，如果内容滚动视图正在减速滚动，会中断滚动并固定在吸顶位置
    /// 当为 false 时：从未完全吸顶过渡到完全吸顶时，允许内容滚动视图的惯性滚动继续进行
    public var interruptsScrollingWhenTransitioningToFullStick: Bool = false

    public weak var dataSource: NestedPageViewControllerDataSource?
    public weak var delegate: NestedPageViewControllerDelegate?
    
    // MARK: - Internal Properties
    
    internal var containerView: UIView = UIView()
    
    internal var currentContentScrollView: UIScrollView? {
        return childManager.currentContentScrollView
    }

    internal var contentScrollViewY: CGFloat {
        return childManager.contentScrollViewY
    }
    
    internal var isRotating: Bool = false
    
    // MARK: - Private Properties
    
    private let headerManager: NestedPageHeaderManager
    private let childManager: NestedPageChildManager
    private let scrollCoordinator: NestedPageScrollCoordinator
        
    // MARK: - Initialization
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        (self.headerManager, self.childManager, self.scrollCoordinator) = Self.createManagers()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {

        (self.headerManager, self.childManager, self.scrollCoordinator) = Self.createManagers()
        
        super.init(coder: coder)
        
        commonInit()
    }
    
    private static func createManagers() -> (NestedPageHeaderManager, NestedPageChildManager, NestedPageScrollCoordinator) {
        let headerManager = NestedPageHeaderManager(viewController: nil)
        let childManager = NestedPageChildManager(viewController: nil, headerManager: headerManager)
        let scrollCoordinator = NestedPageScrollCoordinator(viewController: nil, headerManager: headerManager, childManager: childManager)
        
        return (headerManager, childManager, scrollCoordinator)
    }
    
    private func commonInit() {
        self.headerManager.viewController = self
        self.childManager.viewController = self
        self.scrollCoordinator.viewController = self
        
        self.childManager.scrollCoordinator = scrollCoordinator
    }

    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        self.headerManager.setupAfterViewControllerSet()
        
        setupViews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if childManager.viewControllerMap.isEmpty {
            reloadData()
        }
    }
    
    open override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if view.backgroundColor == nil {
            view.backgroundColor = .systemBackground
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        isRotating = true
        coordinator.animate(alongsideTransition: {_ in 
            // 在旋转动画过程中，更新布局
            self.updateLayouts()
        }) { _ in 
            self.isRotating = false
        }
    }
    
    // MARK: - Public Methods
    
    /// 横向滚动到指定索引的页面
    /// - Parameters:
    ///   - index: 目标页面索引
    ///   - animated: 是否使用动画效果
    open func scrollToPage(at index: Int, animated: Bool) {
        guard let dataSource = dataSource,
              index >= 0 && index < dataSource.numberOfViewControllers(in: self) else {
            return
        }
        // 会触发scrollViewDidScroll
        containerScrollView.setContentOffset(CGPoint(x: containerView.bounds.width * CGFloat(index), y: 0), animated: animated)
    }
    
    /// 将当前内容滚动视图滚动到顶部
    /// - Parameter animated: 是否使用动画效果，默认为true
    public func scrollToTop(animated: Bool = true) {
        guard let scrollView = currentContentScrollView else { return }
        scrollView.scrollToTop(animated: animated)
    }
    
    /// 获取指定索引位置的子视图控制器
    /// - Parameter index: 子控制器的索引
    /// - Returns: 返回实现了NestedPageScrollable协议的视图控制器，如果不存在则返回nil
    public func viewController(at index: Int) -> (UIViewController & NestedPageScrollable)? {
        return childManager.viewController(at: index)
    }
        
    /// 重新加载所有数据，该方法会重建所有数据，包括子视图、头部视图等全部组件
    open func reloadData() {
        // 清理旧数据
        cleanupOldData()
        
        guard let _ = dataSource else { return }
        
        // 重新配置数据
        headerManager.configureHeaderData()
        childManager.loadViewControllers()
        
        // 布局
        updateLayouts()
    }
    
    /// 重新加载所有子页面，该方法仅重新加载子页面
    open func reloadPages() {
        childManager.reloadPages()
    }
    
    /// 更新所有布局，例如头部视图高度发生变化调用。
    open func updateLayouts() {
        
        setupContainerFrame()
        
        let viewWidth = containerView.bounds.width
        let viewHeight = containerView.bounds.height
        
        // 确保headerContentView在正确的位置
        if let pageHeader = headerManager.pageHeader(at: currentIndex) {
            pageHeader.frame = CGRect(x: 0, y: -headerManager.pageHeaderHeight, width: viewWidth, height: headerManager.pageHeaderHeight)
        }
        headerManager.updateHeaderContentViewFrame()
        // 获取数据源信息
        headerManager.fetchHeaderHeights()
        
        // 重新布局头部视图
        headerManager.layoutPageHeader()
        headerManager.layoutHeaderViews()
        
        // 更新子控制器布局
        childManager.updateChildrenLayouts()
        
        // 重置内部状态变量
        headerManager.previousPinY = headerManager.pin.frame.minY
        headerManager.keepsStick = false
        scrollCoordinator.reset()
                
        guard let dataSource = dataSource else { return }
        
        let vcCount = dataSource.numberOfViewControllers(in: self)
        containerScrollView.contentSize = CGSize(width: viewWidth * CGFloat(vcCount), height: viewHeight)
        // 重新滚动到当前页面
        containerScrollView.setContentOffset(CGPoint(x: viewWidth * CGFloat(currentIndex), y: 0), animated: false)
        
        // 强制更新布局
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    // MARK: - Private Methods
        
    private func setupViews() {
                
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(containerView)
        
        containerScrollView.isPagingEnabled = true
        containerScrollView.bounces = false
        containerScrollView.showsHorizontalScrollIndicator = false
        containerScrollView.showsVerticalScrollIndicator = false
        containerScrollView.scrollsToTop = false
        containerScrollView.contentInsetAdjustmentBehavior = .never
        containerScrollView.isScrollEnabled = allowsSwipeToChangePage
        containerScrollView.delegate = self
        containerView.addSubview(containerScrollView)
                        
        if let NestedPageContainerScrollView = containerScrollView as? NestedPageContainerScrollView {
            NestedPageContainerScrollView.headerContentView = headerManager.headerContentView
        }
    }
    
    private func setupContainerFrame() {
        let insetsTop = automaticallyAdjustsContainerInsets ? max(view.safeAreaInsets.top, containerInsets.top) : containerInsets.top
        let insetsBottom = automaticallyAdjustsContainerInsets ? max(view.safeAreaInsets.bottom, containerInsets.bottom) : containerInsets.bottom
        containerView.frame = CGRectMake(0, insetsTop, view.bounds.width, view.bounds.height - insetsTop - insetsBottom)
        containerScrollView.frame = containerView.bounds
    }
    
    private func cleanupOldData() {
        headerManager.cleanupOldData()
        childManager.cleanupOldData()
    }
    
    private func updateScrollEnabled() {
        containerScrollView.isScrollEnabled = allowsSwipeToChangePage
    }

}

// MARK: - UIScrollViewDelegate

extension NestedPageViewController: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCoordinator.handleHorizontalScrollDidScroll(scrollView)
    }
    
    // 手指拖拽 -> 松手 -> （如果有速度则继续减速）-> 完全静止
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollCoordinator.handleScrollViewDidEndDecelerating(scrollView)
    }
    
    // 手指拖拽 -> 松手 -> decelerate == false代表立即静止（无惯性减速，不会触发scrollViewDidEndDecelerating）
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollCoordinator.handleScrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    // 当调用setContentOffset(animated: true)时才会执行
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollCoordinator.handleScrollViewDidEndScrollingAnimation(scrollView)
    }

}

public extension NestedPageViewControllerDataSource {
    
    func heightForTabStrip(in pageViewController: NestedPageViewController) -> CGFloat {
        return 50.0
    }

    func titlesForTabStrip(in pageViewController: NestedPageViewController) -> [String]? {
        return nil
    }
}

public extension NestedPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: NestedPageViewController, didScrollToPageAt index: Int) {}
    func pageViewController(_ pageViewController: NestedPageViewController, contentScrollViewDidScroll scrollView: UIScrollView, headerOffset: CGFloat, isSticked: Bool) {}
}

