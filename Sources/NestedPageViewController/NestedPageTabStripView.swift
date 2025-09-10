//
//  NestedPageTabStripView.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/1/24.
//  Copyright © 2025 SPStore. All rights reserved.
//
//  本组件作为分页控制器的内置标签栏，其设计本意是开箱即用，如果需要更复杂的标签栏样式，请自定义或者使用其它开源组件。

import UIKit

/// TabStrip的配置类
public class NestedPageTabStripConfiguration: NSObject {
    
    /// 标题数组
    public var titles: [String] = []
    
    /// 普通状态下的标题颜色，默认：UIColor.gray
    public var titleColor: UIColor = .gray
    
    /// 选中状态下的标题颜色，默认：UIColor.black
    public var titleSelectedColor: UIColor = .black
    
    /// 标题字体，默认：UIFont.systemFont(ofSize: 16)
    public var titleFont: UIFont = .systemFont(ofSize: 16)
    
    /// 背景颜色，默认：UIColor.white
    public var backgroundColor: UIColor = .white
    
    /// 指示器图片
    public var indicatorImage: UIImage?
    
    /// 指示器大小，默认：CGSize(width: 20, height: 3)
    public var indicatorSize: CGSize = CGSize(width: 20, height: 3)
    
    /// 内容边距，默认：UIEdgeInsets.zero
    public var contentEdgeInsets: UIEdgeInsets = .zero
    
    /// 创建默认配置
    public static func defaultConfiguration() -> NestedPageTabStripConfiguration {
        let config = NestedPageTabStripConfiguration()
        config.indicatorImage = defaultIndicatorImage()
        return config
    }
    
    /// 创建默认的圆角矩形指示器
    private static func defaultIndicatorImage() -> UIImage {
        let image = indicatorImage(with: .systemYellow,
                                   size: CGSize(width: 20, height: 3),
                                   cornerRadius: 1.5)
        return image.withRenderingMode(.alwaysTemplate)

    }
    
    private static func indicatorImage(with color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image {_ in 
            // 设置填充颜色
            color.setFill()
            
            // 创建圆角矩形路径
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                   cornerRadius: cornerRadius)
            path.fill()
        }
    }
}

public protocol NestedPageTabStripViewDelegate: AnyObject {
    
    /// 标题选中时的回调（点击或滚动选中）
    func tabStripView(_ tabStripView: NestedPageTabStripView, didSelectTabAt index: Int)
}

/// 内置的简单TabStrip视图
open class NestedPageTabStripView: UIView {
    
    // MARK: - Public Properties
    
    /// 便利构造器：使用标题数组初始化
    public convenience init(titles: [String]) {
        let config = NestedPageTabStripConfiguration.defaultConfiguration()
        config.titles = titles
        self.init(configuration: config)
    }
    
    /// 使用配置初始化
    public init(configuration: NestedPageTabStripConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        // 初始化完成后立即加载内容
        reloadContent()
    }
    
    public override init(frame: CGRect) {
        self.configuration = NestedPageTabStripConfiguration.defaultConfiguration()
        super.init(frame: frame)
        setupViews()
        if !configuration.titles.isEmpty {
            reloadContent()
        }
    }
    
    public required init?(coder: NSCoder) {
        self.configuration = NestedPageTabStripConfiguration.defaultConfiguration()
        super.init(coder: coder)
        setupViews()
        // 如果配置中已有标题，则立即刷新内容
        if !configuration.titles.isEmpty {
            reloadContent()
        }
    }
    
    public var titles: [String] {
        get { return configuration.titles }
        set {
            configuration.titles = newValue
            reloadContent()
        }
    }
    
    /// 配置对象
    public var configuration: NestedPageTabStripConfiguration {
        didSet {
            reloadContent()
        }
    }
    
    public weak var delegate: NestedPageTabStripViewDelegate?
    
    /// 当前选中的索引
    public private(set) var selectedIndex: Int = 0
    
    /// 关联的容器滚动视图（用于联动）
    public weak var linkedScrollView: UIScrollView? {
        didSet {
            if let oldScrollView = oldValue {
                oldScrollView.removeObserver(self, forKeyPath: "contentOffset")
            }
            
            if let newScrollView = linkedScrollView {
                newScrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var stackView = UIStackView()
    private var titleButtons: [UIButton] = []
    private var indicatorView = UIImageView()
    private var isScrollingProgrammatically = false
    
    // MARK: - Setup
    
    private func setupViews() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0;
        addSubview(stackView)
        
        tintColor = .systemYellow
        
        addSubview(indicatorView)
        
        titleButtons = []
    }
    
    private func reloadContent() {
        for button in titleButtons {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        titleButtons.removeAll()
        
        for (index, title) in titles.enumerated() {
            let button = createTitleButton(with: title, index: index)
            stackView.addArrangedSubview(button)
            titleButtons.append(button)
        }
        
        updateAppearance()
        setNeedsLayout()
                
        // 确保指示器在下一个runloop中正确布局（此时按钮已经有正确的frame）
        DispatchQueue.main.async { [weak self] in
            self?.layoutIndicator()
        }
    }
    
    private func createTitleButton(with title: String, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(configuration.titleColor, for: .normal)
        button.titleLabel?.font = configuration.titleFont
        button.tag = index
        button.addTarget(self, action: #selector(titleButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 根据contentEdgeInsets设置StackView的frame
        let insets = configuration.contentEdgeInsets
        let stackFrame = bounds.inset(by: insets)
        stackView.frame = stackFrame
        
        DispatchQueue.main.async { [weak self] in
            self?.layoutIndicator()
        }
    }
    
    public func layoutIndicator() {
        guard !titleButtons.isEmpty && selectedIndex < titleButtons.count else {
            return
        }
        
        let selectedButton = titleButtons[selectedIndex]
                
        // 将按钮的中心点从stackView坐标系转换到TabStripView坐标系
        let buttonCenterInTabStrip = stackView.convert(selectedButton.center, to: self)
        
        let indicatorX = buttonCenterInTabStrip.x - configuration.indicatorSize.width / 2.0
        let indicatorY = bounds.height - configuration.indicatorSize.height - configuration.contentEdgeInsets.bottom
        
        indicatorView.frame = CGRect(x: indicatorX, y: indicatorY,
                                   width: configuration.indicatorSize.width,
                                   height: configuration.indicatorSize.height)
    }
        
    // MARK: - Public Methods
    
    /// 选中指定索引的标题
    public func selectTab(at index: Int, animated: Bool) {
        guard index >= 0 && index < titleButtons.count && index != selectedIndex else {
            return
        }
        
        if #available(iOS 17.4, *) {
            // 17.4系统开始，通过isScrollAnimating判断是否在执行setContentOffset动画
        } else {
            isScrollingProgrammatically = true
        }
        
        selectedIndex = index
        updateAppearance()
        updateIndicatorPosition(animated: animated)
        
        // 让关联的linkedScrollView滚动到对应页面
        scrollLinkedScrollView(to: index, animated: true)
        
        // 通知代理
        delegate?.tabStripView(self, didSelectTabAt: index)
        
        // 在scrollView滚动动画结束之后，重置isScrollingProgrammatically，这里对时间的要求不用太严格，只要能重置不要太晚即可。
        if #available(iOS 17.4, *) {
            // 17.4系统开始，通过isScrollAnimating判断是否在执行setContentOffset动画
        } else {
            let delay: TimeInterval = animated ? 0.3 : 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.isScrollingProgrammatically = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func titleButtonTapped(_ button: UIButton) {
        let index = button.tag
        selectTab(at: index, animated: true)
    }
    
    private func updateAppearance() {
        backgroundColor = configuration.backgroundColor
        
        // 更新指示器
        indicatorView.image = configuration.indicatorImage
        
        // 更新按钮外观
        for (index, button) in titleButtons.enumerated() {
            let isSelected = (index == selectedIndex)
            
            let color = isSelected ? configuration.titleSelectedColor : configuration.titleColor
            button.setTitleColor(color, for: .normal)
            button.titleLabel?.font = configuration.titleFont
        }
    }
    
    private func updateIndicatorPosition(animated: Bool) {
        let updateBlock = {
            self.layoutIndicator()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
    
    private func scrollLinkedScrollView(to index: Int, animated: Bool) {
        guard let linkedScrollView = linkedScrollView,
              index >= 0 && index < titleButtons.count else {
            return
        }
        
        // 计算目标页面的偏移量
        let pageWidth = linkedScrollView.bounds.width
        let targetOffsetX = CGFloat(index) * pageWidth
        let targetOffset = CGPoint(x: targetOffsetX, y: linkedScrollView.contentOffset.y)
        
        // 滚动到目标位置
        linkedScrollView.setContentOffset(targetOffset, animated: animated)
    }
    
    // MARK: - Content ScrollView Support
    
    @objc public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" && object as? UIScrollView == linkedScrollView {
            handleLinkedScrollViewDidScroll()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func handleLinkedScrollViewDidScroll() {
        var isScrollAnimating = false
        if #available(iOS 17.4, *) {
            isScrollAnimating = linkedScrollView?.isScrollAnimating ?? false
        } else {
            isScrollAnimating = isScrollingProgrammatically
        }
        
        guard let linkedScrollView = linkedScrollView,
              !titleButtons.isEmpty,
              !isScrollAnimating else {
            return
        }
        
        let pageWidth = linkedScrollView.bounds.width
        let contentOffsetX = linkedScrollView.contentOffset.x
        
        // 计算当前页面索引（用于按钮状态更新）
        var currentIndex = Int(round(contentOffsetX / pageWidth))
        currentIndex = max(0, min(currentIndex, titleButtons.count - 1))
        
        // 更新按钮选中状态（只在索引变化时）
        if currentIndex != selectedIndex {
            selectedIndex = currentIndex
            updateAppearance()
            
            // 通知代理
            delegate?.tabStripView(self, didSelectTabAt: currentIndex)
        }
        
        // 实时更新指示器位置（跟随滚动进度）
        updateIndicatorPosition(with: contentOffsetX, pageWidth: pageWidth)
    }
    
    private func updateIndicatorPosition(with contentOffsetX: CGFloat, pageWidth: CGFloat) {
        guard titleButtons.count >= 2 && pageWidth > 0 else {
            return
        }
        
        // 计算滚动进度
        var progress = contentOffsetX / pageWidth
        progress = max(0, min(progress, CGFloat(titleButtons.count - 1)))
        
        // 获取当前页和下一页的索引
        let fromIndex = Int(floor(progress))
        let toIndex = Int(ceil(progress))
        
        // 确保索引范围有效
        let validFromIndex = max(0, min(fromIndex, titleButtons.count - 1))
        let validToIndex = max(0, min(toIndex, titleButtons.count - 1))
        
        // 计算插值比例
        let ratio = progress - CGFloat(fromIndex)
        
        // 获取两个按钮的位置
        let fromButton = titleButtons[validFromIndex]
        let toButton = titleButtons[validToIndex]
        
        let fromCenter = stackView.convert(fromButton.center, to: self)
        let toCenter = stackView.convert(toButton.center, to: self)
        
        // 插值计算指示器的X位置
        let indicatorCenterX = fromCenter.x + (toCenter.x - fromCenter.x) * ratio
        let indicatorX = indicatorCenterX - configuration.indicatorSize.width / 2.0
        let indicatorY = bounds.height - configuration.indicatorSize.height - configuration.contentEdgeInsets.bottom
        
        // 更新指示器位置
        indicatorView.frame = CGRect(x: indicatorX, y: indicatorY,
                                   width: configuration.indicatorSize.width,
                                   height: configuration.indicatorSize.height)
    }
    
    // MARK: - Dealloc
    
    deinit {
        if let linkedScrollView = linkedScrollView {
            linkedScrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
}
