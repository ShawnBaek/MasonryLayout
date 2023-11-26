//
//  MasonryLayoutProvider.swift
//  MasonryLayoutSample
//
//  Created by Sungwook Baek on 11/13/23.
//

import Foundation
import UIKit

final class MasonryLayoutProvider {
    private let columns: CGFloat
    private var columnHeights: [CGFloat]
    private let interItemSpacing: CGFloat
    private let collectionWidth: CGFloat
    private let heightProvider: (Int, CGFloat) -> CGFloat
    private let contentInsets: NSDirectionalEdgeInsets
    
    init(
        columns: CGFloat,
        interItemSpacing: CGFloat,
        collectionWidth: CGFloat,
        contentInsets: NSDirectionalEdgeInsets = .zero,
        heightProvider: @escaping (Int, CGFloat) -> CGFloat
    ) {
        self.columnHeights = [CGFloat](repeating: 0, count: Int(columns))
        self.columns = columns
        self.interItemSpacing = interItemSpacing
        self.collectionWidth = collectionWidth
        self.heightProvider = heightProvider
        self.contentInsets = contentInsets
    }
    
    func makeLayoutItem(for row: Int) -> NSCollectionLayoutGroupCustomItem {
        let frame = frame(for: row)
        columnHeights[columnIndex()] = frame.maxY + interItemSpacing
        return NSCollectionLayoutGroupCustomItem(frame: frame)
    }
    
    func maxColumnHeight() -> CGFloat {
        columnHeights.max() ?? 0
    }
    
    private var columnWidth: CGFloat {
        let horizontalSpacing = contentInsets.leading + contentInsets.trailing
        let spacing = (columns - 1) * interItemSpacing + horizontalSpacing
        return (collectionWidth - spacing) / columns
    }
    
    func frame(for row: Int) -> CGRect {
        let width = columnWidth
        let height = heightProvider(row, columnWidth)
        let size = CGSize(width: width, height: height)
        let origin = itemOrigin(width: size.width)
        return CGRect(origin: origin, size: size)
    }
    
    private func itemOrigin(width: CGFloat) -> CGPoint {
        let y = columnHeights[columnIndex()].rounded()
        let x = (width + interItemSpacing) * CGFloat(columnIndex())
        return CGPoint(x: x, y: y)
    }
    
    private func columnIndex() -> Int {
        columnHeights
            .enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }
}
