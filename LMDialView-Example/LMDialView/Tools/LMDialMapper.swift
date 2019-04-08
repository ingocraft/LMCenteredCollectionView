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
    
    private let cellInterval: CGFloat
    private let cellCount: Int
    private let cycleCount: Int
    private let viewWidth: CGFloat
    
    private lazy var startIndex: Int = {
        return (cellCount - cycleCount) / 2
    }()
    private lazy var endIndex: Int = {
        return startIndex + cycleCount - 1
    }()
    private lazy var startOffsetX: CGFloat = {
        return CGFloat(startIndex) * cellInterval - viewWidth / 2
    }()
    private lazy var endOffsetX: CGFloat = {
        return CGFloat(endIndex) * cellInterval - viewWidth / 2
    }()

    init(cellInterval: CGFloat, cellCount: Int, cycleCount: Int, viewWidth: CGFloat) {
        self.cellInterval = cellInterval
        self.cellCount = cellCount
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
        return scrollOffset - startOffsetX
    }
    
    func scrollOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        return dialOffset + startOffsetX
    }
}

/*
 These maps are irreversible,
 dialOffset -> cycleDialOffset
 */
extension LMDialMapper {
    func cycleDialOffsetFrom(dialOffset: CGFloat) -> CGFloat {
        if dialOffset < 0 {
            return endDialOffset - dialOffset
        } else {
            return dialOffset
        }
    }
}

// MARK: utility
private extension LMDialMapper {
    func cloestDividingLineOffsetX(from scrollOffsetX: CGFloat) -> CGFloat {
        let dialOffsetX = dialOffsetFrom(scrollOffset: scrollOffsetX)
        let prevIndex = CGFloat(floor(Double(dialOffsetX / cellInterval)))
        let prevOffsetX = prevIndex * cellInterval
        let nextOffsetX = prevOffsetX + cellInterval
        let distanceToPrev = dialOffsetX - prevOffsetX
        let distanceToNext = nextOffsetX - dialOffsetX
        
        let cloestOffsetX: CGFloat
        if distanceToPrev < distanceToNext {
            cloestOffsetX = prevOffsetX
        } else {
            cloestOffsetX = nextOffsetX
        }
        
        return scrollOffsetFrom(dialOffset: cloestOffsetX)
    }
}
