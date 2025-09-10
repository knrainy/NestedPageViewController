//
//  PreloadViewController.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/6.
//

import UIKit
import NestedPageViewController

class PreloadViewController: UIViewController {
    
    // MARK: - Properties
    
    private var nestedPageViewController = NestedPageViewController()
    private var coverView: UIView = UIView()
    private var coverBgImageView: UIImageView = UIImageView()
    
    // MARK: - View Controllers
    
    private let childControllerTitles = ["作品", "推荐", "收藏", "喜欢"]
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "预加载子视图控制器"
        view.backgroundColor = .systemBackground
        
        let _ = createCoverView()
        setupNestedPageViewController()
    }
    
    // MARK: - Setup

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupNestedPageViewController() {
        nestedPageViewController.dataSource = self
        nestedPageViewController.delegate = self
        
        // 索引号顺序代表加载顺序，1表示优先加载第2个，默认选中的索引号为1
        nestedPageViewController.preloadViewControllerIndexes = [1, 0, 2, 3]
        
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

extension PreloadViewController: NestedPageViewControllerDataSource {
    
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
        return nil  // 使用内置的标签栏
    }
    
    func heightForTabStrip(in pageViewController: NestedPageViewController) -> CGFloat {
        return 50.0
    }
    
    func titlesForTabStrip(in pageViewController: NestedPageViewController) -> [String]? {
        return childControllerTitles
    }
}

// MARK: - NestedPageViewControllerDelegate

extension PreloadViewController: NestedPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: NestedPageViewController, didScrollToPageAt index: Int) {

    }
    
    func pageViewController(_ pageViewController: NestedPageViewController,
                            contentScrollViewDidScroll scrollView: UIScrollView,
                            headerOffset: CGFloat,
                            isSticked: Bool) {
        
    }
}
