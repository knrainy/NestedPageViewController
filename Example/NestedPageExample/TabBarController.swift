//
//  MainTabBarController.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/1/25.
//  Copyright © 2025 SPStore. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 创建示例列表导航控制器
        let exampleListVC = ExampleListViewController()
        let exampleNavController = NavigationController(rootViewController: exampleListVC)
        exampleNavController.tabBarItem = UITabBarItem(
            title: "示例",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet.circle.fill")
        )
        
        // 创建设置页面导航控制器
        let settingsVC = SettingsViewController()
        let settingsNavController = NavigationController(rootViewController: settingsVC)
        settingsNavController.tabBarItem = UITabBarItem(
            title: "设置",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        // 设置视图控制器
        viewControllers = [exampleNavController, settingsNavController]
        
        // 配置TabBar外观
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
}
