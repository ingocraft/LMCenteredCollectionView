//
//  LMDialManager.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialManager {
    private(set) var cycleCellCount: Int = 50
    private(set) var cellLength: CGFloat = 40
    private(set) var interSpace: CGFloat = 10
    private(set) var viewLength: CGFloat

    private var dialMapper: LMDialMapper!
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

    init(cycleCellCount: Int?, cellLength: CGFloat?, interSpace: CGFloat?, viewLength: CGFloat) {
        if let cycleCellCount = cycleCellCount {
            self.cycleCellCount = cycleCellCount
        }
        if let cellLength = cellLength {
            self.cellLength = cellLength
        }
        if let interSpace = interSpace {
            self.interSpace = interSpace
        }
        self.viewLength = viewLength

        updateDialInfo(cycleCellCount: self.cycleCellCount,
                       cellLength: self.cellLength,
                       interSpace: self.interSpace,
                       viewLength: self.viewLength)
    }
}

// MARK: internal
extension LMDialManager {
    func update(cycleCellCount: Int?, cellLength: CGFloat?, interSpace: CGFloat?, viewLength: CGFloat?) {
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
        let greaterThanEnd = dialOffset >= endDialOffset + cellInterval

        let offset: CGFloat
        if lessThanStart {
            offset = endOffset + cellInterval + dialOffset
        } else if greaterThanEnd {
            offset = startOffset + (dialOffset -  endDialOffset - cellInterval)
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
        let offset = dialOffset - cellLength / 2
        let floatDialIndex = offset / cellInterval
        var dialIndex = Int(floatDialIndex.rounded())
        if dialIndex == cycleCellCount {
            dialIndex = 0
        }
        return dialIndex
    }
    
    func middleScrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        let scrollOffset = dialMapper.scrollOffsetFrom(dialOffset: dialOffset)
        let middleScrollOffset = scrollOffset + cellLength / 2
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
    func updateDialInfo(cycleCellCount: Int, cellLength: CGFloat, interSpace: CGFloat, viewLength: CGFloat) {
        let space = interSpace + cellLength

        // calculate cell count
        /// cell's count in the given width
        let cellsInWidth = Int(ceil(viewLength / space))
        /// add two extra cell in case `floor` decrease cell's count
        let bias = 100
        let cellCount = cycleCellCount + cellsInWidth + bias
        
        dialMapper = LMDialMapper(cellInterval: space,
                                  cellCount: cellCount,
                                  cellLength: cellLength,
                                  cycleCount: cycleCellCount,
                                  viewLength: viewLength)
    }
}

