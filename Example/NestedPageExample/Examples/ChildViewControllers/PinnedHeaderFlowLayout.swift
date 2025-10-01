//
//  PinnedHeaderFlowLayout.swift
//  NestedPageExample
//
//  Created by 乐升平 on 2025/9/26.
//

import UIKit

// 自定义sectionHeadersPinToVisibleBounds效果，系统自带的吸顶效果，会考虑contentInset.top，我们这里需要忽略它.
class PinnedHeaderFlowLayout: UICollectionViewFlowLayout {
    
    public var customSectionHeadersPinToVisibleBounds: Bool = false
    
    public var headerHeight: CGFloat = 0
    public var headerOffset: CGFloat = 0

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // 每次滚动都让 layoutAttributesForElements(in:) 被调用
        if customSectionHeadersPinToVisibleBounds {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    // 滚动时执行这个方法有2个前提：
    // 1. shouldInvalidateLayout(forBoundsChange newBounds:)返回true
    // 2. sectionHeadersPinToVisibleBounds = false
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect) ?? []

        guard customSectionHeadersPinToVisibleBounds else {
            return attributes
        }
        
        guard let collectionView = collectionView else { return nil }

        /// 注意：
        /// - `rect` 参数通常表示 **collectionView 的可见区域 + buffer**，因此范围会比实际可见区域大，主要用于 **预加载**。
        /// - 当某个 cell/header/footer 的 `frame` 与 `rect` 完全不相交时，
        ///   `super.layoutAttributesForElements(in:)` 不会返回该元素的 attributes
        /// - 对于需要 **永久吸顶** 的 section header，必须手动将其 attributes 加回结果数组，否则在滑动到超出 buffer 区域后，该 section header 会“消失”。
        ///   现象就是：开始时能正常吸顶，但滑动到一定距离后 section header 不再显示。
        if let headerAttr = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ), !attributes.contains(where: { $0.indexPath == headerAttr.indexPath && $0.representedElementKind == headerAttr.representedElementKind }) {
            attributes.append(headerAttr)
        }

        let offsetY = collectionView.contentOffset.y + headerHeight - max(headerOffset, 0)
        

        for attr in attributes {
            if attr.representedElementKind == UICollectionView.elementKindSectionHeader {
                var frame = attr.frame
                frame.origin.y = max(offsetY, frame.origin.y)
                attr.frame = frame
                attr.zIndex = 1024
            }
        }
        return attributes
    }

}
