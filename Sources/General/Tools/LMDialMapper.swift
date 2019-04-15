//
//  LMDialMapper.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/3.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialMapper {
    lazy var endDialOffset: CGFloat = {
        return cellInterval * CGFloat(endDialIndex)
    }()
    lazy var endDialIndex: Int = {
        return cycleCount - 1
    }()
    
    let cellInterval: CGFloat
    let cellCount: Int
    let cellWidth: CGFloat
    let cycleCount: Int
    let viewWidth: CGFloat
    
    private(set) lazy var startIndex: Int = {
        return (cellCount - cycleCount) / 2
    }()
    private(set) lazy var endIndex: Int = {
        return startIndex + cycleCount - 1
    }()
    private(set) lazy var startOffset: CGFloat = {
        return CGFloat(startIndex) * cellInterval - viewWidth / 2
    }()
    private(set) lazy var endOffset: CGFloat = {
        return CGFloat(endIndex) * cellInterval - viewWidth / 2
    }()

    init(cellInterval: CGFloat, cellCount: Int, cellWidth: CGFloat, cycleCount: Int, viewWidth: CGFloat) {
        self.cellInterval = cellInterval
        self.cellCount = cellCount
        self.cellWidth = cellWidth
        self.cycleCount = cycleCount
        self.viewWidth = viewWidth
    }
}

// MARK: internal
/*
 These maps are lossless,
 scrollIndex -> scrollOffset, dialIndex -> dialOffset, scrollOffset <-> dialOffset
 
 And these maps can only return approximation,
 scrollOffset -> scrollIndex, dialOffset -> dialIndex
 */
extension LMDialMapper {
    func scrollOffsetFrom(scrollIndex: Int) -> CGFloat {
        return CGFloat(scrollIndex) * cellInterval
    }
    
    func dialOffsetFrom(dialIndex: Int) -> CGFloat {
        return CGFloat(dialIndex) * cellInterval
    }
    
    func dialOffsetFrom(scrollOffset: CGFloat) -> CGFloat {
        return scrollOffset - startOffset
    }
    
    func scrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        return dialOffset + startOffset
    }
}

/*
 These maps are irreversible,
 dialOffset -> cycleDialOffset
 */
extension LMDialMapper {
    func cycleDialOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        var cycleDialOffset: CGFloat
        if dialOffset < 0 {
            cycleDialOffset = endDialOffset - dialOffset
        } else {
            cycleDialOffset = dialOffset
        }
        return cycleDialOffset
    }
    
    func cycleDialIndexFrom(dialIndex: Int) -> Int {
        var cycleDialIndex: Int
        if dialIndex < 0 {
            cycleDialIndex = endIndex - startIndex + dialIndex + 1
        } else if dialIndex > endIndex {
            cycleDialIndex = dialIndex - endIndex
        } else {
            cycleDialIndex = dialIndex
        }
        return cycleDialIndex
    }
}

// MARK: utility
extension LMDialMapper {
    func cloestDividingLineOffsetX(from scrollOffsetX: CGFloat) -> CGFloat {
        let dialOffsetX = dialOffsetFrom(scrollOffset: scrollOffsetX)
        let prevIndex = CGFloat(floor(Double(dialOffsetX / cellInterval)))
        let prevOffsetX = prevIndex * cellInterval
        let nextOffsetX = prevOffsetX + cellInterval
        let distanceToPrev = dialOffsetX - prevOffsetX
        let distanceToNext = nextOffsetX - dialOffsetX

        let cloestOffsetX: CGFloat
        if distanceToPrev < distanceToNext {
            cloestOffsetX = prevOffsetX + cellWidth / 2
        } else {
            cloestOffsetX = nextOffsetX + cellWidth / 2
        }
        
        return scrollOffsetFrom(dialOffset: cloestOffsetX)
    }
}
