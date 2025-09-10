//
//  NestedPageTabStripObjcBridge.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/5.
//

import UIKit
import NestedPageViewController

// MARK: - TabStrip配置类桥接

@objcMembers
public class NestedPageTabStripConfigurationObjcBridge: NSObject {
    public var titles: [String] = []
    public var titleColor: UIColor = .gray
    public var titleSelectedColor: UIColor = .black
    public var titleFont: UIFont = .systemFont(ofSize: 16)
    public var backgroundColor: UIColor = .white
    public var indicatorImage: UIImage?
    public var indicatorSize: CGSize = CGSize(width: 20, height: 3)
    public var contentEdgeInsets: UIEdgeInsets = .zero
    
    private var swiftConfig: NestedPageTabStripConfiguration
    
    public override init() {
        self.swiftConfig = NestedPageTabStripConfiguration()
        super.init()
    }
    
    @objc public static func defaultConfiguration() -> NestedPageTabStripConfigurationObjcBridge {
        let config = NestedPageTabStripConfigurationObjcBridge()
        config.swiftConfig = NestedPageTabStripConfiguration.defaultConfiguration()
        config.syncFromSwiftConfig()
        return config
    }
    
    private func syncFromSwiftConfig() {
        titles = swiftConfig.titles
        titleColor = swiftConfig.titleColor
        titleSelectedColor = swiftConfig.titleSelectedColor
        titleFont = swiftConfig.titleFont
        backgroundColor = swiftConfig.backgroundColor
        indicatorImage = swiftConfig.indicatorImage
        indicatorSize = swiftConfig.indicatorSize
        contentEdgeInsets = swiftConfig.contentEdgeInsets
    }
    
    private func syncToSwiftConfig() {
        swiftConfig.titles = titles
        swiftConfig.titleColor = titleColor
        swiftConfig.titleSelectedColor = titleSelectedColor
        swiftConfig.titleFont = titleFont
        swiftConfig.backgroundColor = backgroundColor
        swiftConfig.indicatorImage = indicatorImage
        swiftConfig.indicatorSize = indicatorSize
        swiftConfig.contentEdgeInsets = contentEdgeInsets
    }
    
    internal var originalConfig: NestedPageTabStripConfiguration {
        syncToSwiftConfig()
        return swiftConfig
    }
}

// MARK: - TabStrip视图代理协议桥接

@objc public protocol NestedPageTabStripViewDelegateObjcBridge: AnyObject {
    @objc optional func tabStripView(_ tabStripView: NestedPageTabStripViewObjcBridge, didSelectTabAt index: Int)
}

// MARK: - TabStrip视图桥接

@objcMembers
public class NestedPageTabStripViewObjcBridge: NSObject {
    public let swiftTabStripView: NestedPageTabStripView
    
    public var titles: [String] {
        get { return swiftTabStripView.titles }
        set { swiftTabStripView.titles = newValue }
    }
    
    public var configuration: NestedPageTabStripConfigurationObjcBridge? {
        didSet {
            if let config = configuration {
                swiftTabStripView.configuration = config.originalConfig
            }
        }
    }
    
    public weak var delegate: NestedPageTabStripViewDelegateObjcBridge? {
        didSet {
            swiftTabStripView.delegate = self
        }
    }
    
    public var selectedIndex: Int {
        return swiftTabStripView.selectedIndex
    }
    
    public var linkedScrollView: UIScrollView? {
        get { return swiftTabStripView.linkedScrollView }
        set { swiftTabStripView.linkedScrollView = newValue }
    }
    
    public init(titles: [String]) {
        self.swiftTabStripView = NestedPageTabStripView(titles: titles)
        super.init()
        setupView()
    }
    
    public init(configuration: NestedPageTabStripConfigurationObjcBridge) {
        self.swiftTabStripView = NestedPageTabStripView(configuration: configuration.originalConfig)
        super.init()
        self.configuration = configuration
        setupView()
    }
    
    public init(frame: CGRect) {
        self.swiftTabStripView = NestedPageTabStripView(frame: frame)
        super.init()
        setupView()
    }
    
    private func setupView() {
        swiftTabStripView.delegate = self
    }
    
    public func selectTab(at index: Int, animated: Bool) {
        swiftTabStripView.selectTab(at: index, animated: animated)
    }
}

// MARK: - NestedPageTabStripViewDelegate 实现

extension NestedPageTabStripViewObjcBridge: NestedPageTabStripViewDelegate {
    public func tabStripView(_ tabStripView: NestedPageTabStripView, didSelectTabAt index: Int) {
        delegate?.tabStripView?(self, didSelectTabAt: index)
    }
}
