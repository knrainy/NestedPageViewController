//
//  NoHeaderViewController.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/25.
//

import UIKit
import NestedPageViewController

class NoHeaderViewController: UIViewController {
    
    // MARK: - Properties
    
    private var nestedPageViewController = NestedPageViewController()
    
    private lazy var tabStripView: NestedPageTabStripView = {
        var config = NestedPageTabStripConfiguration()
        config.titles = ["作品", "推荐"]
        config.titleColor = .secondaryLabel
        config.titleFont = .boldSystemFont(ofSize: 17)
        config.titleSelectedColor = .label
        config.indicatorSize = CGSize(width: 20, height: 3)
        config.spacing = 20
        let tabStripView = NestedPageTabStripView(configuration: config)
        return tabStripView
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = self.tabStripView
        view.backgroundColor = .systemBackground
        
        setupNestedPageViewController()
        
        tabStripView.linkedScrollView = nestedPageViewController.containerScrollView
    }
    
    // MARK: - Setup

    private func setupNestedPageViewController() {
        nestedPageViewController.dataSource = self
        // 先加载第2页，再加载第1页；这样tabStrip的索引号会自动切到第2个
        nestedPageViewController.defaultPageIndex = 1
        
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
}

// MARK: - NestedPageViewControllerDataSource

extension NoHeaderViewController: NestedPageViewControllerDataSource {
    
    func numberOfViewControllers(in pageViewController: NestedPageViewController) -> Int {
        return 2
    }
    
    func pageViewController(_ pageViewController: NestedPageViewController, viewControllerAt index: Int) -> NestedPageScrollable? {
        switch index {
        case 0:
            let vc = DefaultListViewController()
            vc.title = tabStripView.configuration.titles[0]
            return vc
        case 1:
            let vc = DefaultListViewController()
            vc.title = tabStripView.configuration.titles[1]
            return vc
        default:
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: NestedPageViewController, shouldPreloadViewControllerAt index: Int) -> Bool {
        return true
    }
}
