//
//  LMCenteredCollectionViewManager.swift
//  LMCenteredCollectionView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMCenteredCollectionViewManager {
    private(set) var cycleCellCount: Int
    private(set) var cellLength: CGFloat
    private(set) var interitemSpacing: CGFloat
    private(set) var viewLength: CGFloat

    private var dialMapper: LMCenteredCollectionViewMapper!
    var cellCount: Int {
        return dialMapper.cellCount
    }
    private var startIndex: Int {
        return dialMapper.startIndex
    }
    private var endIndex: Int {
        return dialMapper.endIndex
    }
    private var startOffset: CGFloat {
        return dialMapper.startOffset
    }
    private var endOffset: CGFloat {
        return dialMapper.endOffset
    }
    private var cellInterval: CGFloat {
        return dialMapper.cellInterval
    }

    init(cycleCellCount: Int, cellLength: CGFloat, interSpace: CGFloat, viewLength: CGFloat) {
        self.cycleCellCount = cycleCellCount
        self.cellLength = cellLength
        self.interitemSpacing = interSpace
        self.viewLength = viewLength

        updateDialInfo(cycleCellCount: cycleCellCount,
                       cellLength: cellLength,
                       interSpace: interitemSpacing,
                       viewLength: viewLength)
    }
}

// MARK: internal
extension LMCenteredCollectionViewManager {
    func update(cycleCellCount: Int?, cellLength: CGFloat?, interSpace: CGFloat?, viewLength: CGFloat?) {
    }
}

// MARK: internal
extension LMCenteredCollectionViewManager {
    func indexFromIndexPath(_ indexPath: IndexPath) -> Int {
        let item = indexPath.item
        if item < startIndex {
            let offset = startIndex - item
            return cycleCellCount - offset
        } else if item > endIndex {
            let offset = item - endIndex
            return offset - 1
        } else {
            return item - startIndex
        }
    }
    
    /**
     Figure out the contentOffset which should scroll to manually
     
     - Parameters:
        - scrollOffset: The current contentOffset.

     - Returns: The final contentOffset which should scroll to
     */
    func calculateScrollOffsetFrom(scrollOffset: CGFloat) -> CGFloat {
        let dialOffset = dialMapper.dialOffsetFrom(scrollOffset: scrollOffset)
        let minimum = -cellInterval / 2
        let maximum = CGFloat(cycleCellCount - 1) * cellInterval + cellInterval / 2
        let lessThanStart = dialOffset < minimum
        let greaterThanEnd = dialOffset >= maximum

        let offset: CGFloat
        if lessThanStart {
            let diff = CGFloat(fabs(Double(dialOffset - minimum)))
            offset = endOffset + cellInterval / 2 - diff
        } else if greaterThanEnd {
            let diff = CGFloat(fabs(Double(dialOffset - maximum)))
            offset = startOffset - cellInterval / 2 + diff
        } else {
            offset = scrollOffset
        }
        return offset
    }
    
    /**
     Figure out dial index according to contentOffset
     
     - Parameters:
        - scrollOffset: The current contentOffset
     
     - Returns: Dial index
     */
    func calculateIndexFrom(scrollOffset: CGFloat) -> Int {
        let dialOffset = dialMapper.dialOffsetFrom(scrollOffset: scrollOffset)
        let offset = dialOffset
        let floatDialIndex = offset / cellInterval
        var dialIndex = Int(floatDialIndex.rounded())
        if dialIndex == cycleCellCount {
            dialIndex = 0
        }
        return dialIndex
    }
    
    func middleScrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        let scrollOffset = dialMapper.scrollOffsetFrom(dialOffset: dialOffset)
        let middleScrollOffset = scrollOffset
        return middleScrollOffset
    }
    
    func cycleDialOffsetFrom(scrollOffset: CGFloat) -> CGFloat {
        let dialOffset = dialMapper.dialOffsetFrom(scrollOffset: scrollOffset)
        let cycleDialOffset = dialMapper.cycleDialOffsetFrom(dialOffset: dialOffset)
        return cycleDialOffset
    }
    
    func cycleDialIndexFrom(dialIndex: Int) -> Int {
        return dialMapper.cycleDialIndexFrom(dialIndex: dialIndex)
    }
}

extension LMCenteredCollectionViewManager {
    func scrollOffsetFrom(scrollIndex: Int) -> CGFloat {
        return dialMapper.scrollOffsetFrom(scrollIndex: scrollIndex)
    }
    
    func dialOffsetFrom(dialIndex: Int) -> CGFloat {
        return dialMapper.dialOffsetFrom(dialIndex: dialIndex)
    }
    
    func dialOffsetFrom(scrollOffset: CGFloat) -> CGFloat {
        return dialMapper.dialOffsetFrom(scrollOffset: scrollOffset)
    }
    
    func scrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        return dialMapper.scrollOffsetFrom(dialOffset: dialOffset)
    }
    
    func cloestDividingLineOffsetX(from scrollOffsetX: CGFloat) -> CGFloat {
        return dialMapper.cloestDividingLineOffsetX(from: scrollOffsetX)
    }
}

// MARK: private
private extension LMCenteredCollectionViewManager {
    func updateDialInfo(cycleCellCount: Int, cellLength: CGFloat, interSpace: CGFloat, viewLength: CGFloat) {
        let space = interSpace + cellLength

        // calculate cell count
        /// cell's count in the given width
        let cellsInWidth = Int(ceil(viewLength / space))
        /// If scroll very fast, `targetContentOffset` will be more than max content offset
        /// or less than zero content offset which will lead position mistake.
        /// I did a simple test, when I scroll very fast, the max `targetContentOffset` will be about 70 multiples of space
        /// That's why `bias` is 100.
        let bias = 100
        let cellCount = cycleCellCount + cellsInWidth + bias
        
        dialMapper = LMCenteredCollectionViewMapper(cellInterval: space,
                                  cellCount: cellCount,
                                  cellLength: cellLength,
                                  cycleCount: cycleCellCount,
                                  viewLength: viewLength)
    }
}

