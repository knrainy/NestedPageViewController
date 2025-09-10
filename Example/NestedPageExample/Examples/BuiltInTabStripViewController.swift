//
//  BuiltInTabStripViewController.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/6.
//

import UIKit
import NestedPageViewController

class BuiltInTabStripViewController: UIViewController {
    
    // MARK: - Properties
    
    private var nestedPageViewController = NestedPageViewController()
    private var coverView: UIView = UIView()
    private var coverBgImageView: UIImageView = UIImageView()
    private var tabStripView: NestedPageTabStripView!
    
    // MARK: - View Controllers
    
    private let childControllerTitles = ["作品", "收藏", "喜欢"]
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "简单定制内置tab栏"
        view.backgroundColor = .systemBackground
        
        let _ = createCoverView()
        createTabStripView()
        setupNestedPageViewController()
    }
    
    private func createTabStripView() {
        // 创建标签栏配置
        let tabStripConfig = NestedPageTabStripConfiguration.defaultConfiguration()
        tabStripConfig.titles = childControllerTitles
        tabStripConfig.titleColor = .gray
        tabStripConfig.titleSelectedColor = .systemBlue
        tabStripConfig.titleFont = .systemFont(ofSize: 16, weight: .medium)
        tabStripConfig.backgroundColor = .systemBackground
        tabStripConfig.contentEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 12, right: 50)
        
        // 创建自定义指示器
        let indicatorSize = CGSize(width: 12, height: 3)
        let renderer = UIGraphicsImageRenderer(size: indicatorSize)
        let indicatorImage = renderer.image { context in
            UIColor.systemBlue.setFill()
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: indicatorSize),
                                   cornerRadius: 1.5)
            path.fill()
        }
        tabStripConfig.indicatorImage = indicatorImage
        tabStripConfig.indicatorSize = indicatorSize
                
        // 创建标签栏
        tabStripView = NestedPageTabStripView(configuration: tabStripConfig)
    }
    
    // MARK: - Setup

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNestedPageViewController() {
        nestedPageViewController.dataSource = self
        
        // 应用全局配置
        NestedPageConfig.shared.applyConfig(to: nestedPageViewController)
        
        addChild(nestedPageViewController)
        view.addSubview(nestedPageViewController.view)
        
        // 使用frame布局而不是Auto Layout
        let safeAreaTop = view.safeAreaInsets.top
        nestedPageViewController.view.frame = CGRect(
            x: 0,
            y: safeAreaTop,
            width: view.bounds.width,
            height: view.bounds.height - safeAreaTop
        )
        
        nestedPageViewController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新NestedPageViewController的frame
        let safeAreaTop = view.safeAreaInsets.top
        nestedPageViewController.view.frame = CGRect(
            x: 0,
            y: safeAreaTop,
            width: view.bounds.width,
            height: view.bounds.height - safeAreaTop
        )
    }
        
    private func createCoverView() -> UIView {
        let customCoverView = ProfileCoverView(frame: .zero)
                
        coverView = customCoverView
        coverBgImageView = customCoverView.bgImageView
        return customCoverView
    }
}

// MARK: - NestedPageViewControllerDataSource

extension BuiltInTabStripViewController: NestedPageViewControllerDataSource {
    
    // MARK: - NestedPageViewControllerDataSource
    
    func numberOfViewControllers(in pageViewController: NestedPageViewController) -> Int {
        return childControllerTitles.count
    }
    
    func pageViewController(_ pageViewController: NestedPageViewController, viewControllerAt index: Int) -> (UIViewController & NestedPageScrollable)? {
        guard index >= 0 && index < childControllerTitles.count else { return nil }
        
        switch index {
        case 0:
            return PostsViewController()
        case 1:
            return RecommendsViewController()
        case 2:
            return FavoritesViewController()
        case 3:
            return LikesViewController()
        default:
            return nil
        }
    }
    
    func coverView(in pageViewController: NestedPageViewController) -> UIView? {
        return coverView
    }
    
    func heightForCoverView(in pageViewController: NestedPageViewController) -> CGFloat {
        return 250.0
    }
    
    func tabStrip(in pageViewController: NestedPageViewController) -> UIView? {
        // 将tabStripView与NestedPageViewController的containerScrollView关联，实现联动
        tabStripView.linkedScrollView = pageViewController.containerScrollView
        return tabStripView
    }
    
    func heightForTabStrip(in pageViewController: NestedPageViewController) -> CGFloat {
        return 50.0
    }
    
    func titlesForTabStrip(in pageViewController: NestedPageViewController) -> [String]? {
        return nil  // 由于我们自己创建了tabStripView，这里返回nil
    }
}
