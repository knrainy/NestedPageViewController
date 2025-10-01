//
//  ExampleListViewController.swift
//  NestedPageViewController Examples
//
//  Created by 乐升平 on 2025/1/25.
//  Copyright © 2025 SPStore. All rights reserved.
//
//  示例入口：选择不同的使用方式进入对应示例

import UIKit

class ExampleListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        // 不再注册cell，将在cellForRowAt中创建带样式的cell
        table.backgroundColor = .systemGroupedBackground
        return table
    }()
    
    private var dataSource: [ExampleGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func setupUI() {
        title = "示例列表"
        view.backgroundColor = .systemBackground
        
        navigationItem.backButtonTitle = ""   // 只保留返回箭头
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        dataSource = ExampleTypeModel.demoGroups()
        tableView.reloadData()
    }

}

// MARK: - UITableViewDataSource
extension ExampleListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].examples.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 使用 subtitle 样式的 cell
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ExampleCell")
        let model = dataSource[indexPath.section].examples[indexPath.row]
        
        cell.textLabel?.text = model.title
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.text = model.detailTitle
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 2
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExampleListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.section].examples[indexPath.row]
        let viewController = model.targetClass.init()
        viewController.title = model.title
        switch model.action {
        case .push:
            // 如果不是IncludeTabBarViewController类型，才隐藏TabBar
            if !(viewController is IncludeTabBarViewController) && !(viewController is ObjcExmpleViewController)  {
                viewController.hidesBottomBarWhenPushed = true
            }
            navigationController?.pushViewController(viewController, animated: true)
        case .present:
            let navController = UINavigationController(rootViewController: viewController)
            present(navController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
