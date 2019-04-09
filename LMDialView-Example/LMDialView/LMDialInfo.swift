//
//  DialInfo.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialManager {
    var cellCount: Int {
        return _cellCount
    }
    
    private(set) var cycleCellCount: Int
    private(set) var cellWidth: CGFloat
    private(set) var viewWidth: CGFloat
    private(set) var interSpace: CGFloat

    private var _cellCount: Int = 0
    private var _cellInterval: CGFloat = 0
    private var dialMapper: LMDialMapper!

    var startOffsetX: CGFloat = 0
    var endOffsetX: CGFloat = 0

    var startIndex: Int = 0
    var endIndex: Int = 0
    var firstIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    init() {
        cycleCellCount = 0
        cellWidth = 0
        viewWidth = 0
        interSpace = 0
    }
}

// MARK: internal
extension LMDialManager {
    func update(cycleCellCount: Int, cellWidth: CGFloat, interSpace: CGFloat, viewWidth: CGFloat) {
        self.cycleCellCount = cycleCellCount
        self.cellWidth = cellWidth
        self.interSpace = interSpace
        self.viewWidth = viewWidth
        // add limit
        updateDialInfo(cycleCellCount: cycleCellCount, cellWidth: cellWidth, interSpace: interSpace, viewWidth: viewWidth)
    }
}

// MARK: internal
extension LMDialManager {
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
        let endDialOffset = dialMapper.endDialOffset
        let lessThanStart = dialOffset < 0
        let greaterThanEnd = dialOffset >= endDialOffset + _cellInterval

        let offset: CGFloat
        if lessThanStart {
            offset = endOffsetX + _cellInterval + dialOffset
        } else if greaterThanEnd {
            offset = startOffsetX + (dialOffset -  endDialOffset - _cellInterval)
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
        let offset = dialOffset - cellWidth / 2
        let floatDialIndex = offset / _cellInterval
        var dialIndex = Int(floatDialIndex.rounded())
        if dialIndex == cycleCellCount {
            dialIndex = 0
        }
        return dialIndex
    }
    
    func middleScrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        let scrollOffset = dialMapper.scrollOffsetFrom(dialOffset: dialOffset)
        let middleScrollOffset = scrollOffset + cellWidth / 2
        return middleScrollOffset
    }
    
    func cycleDialOffsetFrom(scrollOffset: CGFloat) -> CGFloat {
        let dialOffset = dialMapper.dialOffsetFrom(scrollOffset: scrollOffset)
        let cycleDialOffset = dialMapper.cycleDialOffsetFrom(dialOffset: dialOffset)
        return cycleDialOffset
    }
}

extension LMDialManager {
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
private extension LMDialManager {
    func updateDialInfo(cycleCellCount: Int, cellWidth: CGFloat, interSpace: CGFloat, viewWidth: CGFloat) {
        let space = interSpace + cellWidth
        _cellInterval = space
        
        // calculate cell count
        /// cell's count in the given width
        let cellsInWidth = Int(ceil(viewWidth / space))
        /// add two extra cell in case `floor` decrease cell's count
        let bias = 100
        _cellCount = cycleCellCount + cellsInWidth + bias
        
        // calculate index
        startIndex = (_cellCount - cycleCellCount) / 2
        endIndex = ((_cellCount + cycleCellCount) / 2) - 1
        firstIndexPath = IndexPath(item: startIndex, section: 0)
        
        // calculate offset
        let halfWidth = viewWidth / 2
        let startCellX = CGFloat(startIndex) * space
        startOffsetX = startCellX - halfWidth
        let endCellX = CGFloat(endIndex) * space
        endOffsetX = endCellX - halfWidth
        
        dialMapper = LMDialMapper(cellInterval: space, cellCount: _cellCount, cellWidth: cellWidth, cycleCount: cycleCellCount, viewWidth: viewWidth)
    }
}

