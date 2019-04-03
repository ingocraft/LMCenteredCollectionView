//
//  LMDialMapper.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/3.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialMapper {
//    var scrollIndex: Int = 0
//    var scrollOffset: CGFloat = 0
//    var dialIndex: Int = 0
//    var dialOffset: CGFloat = 0
    
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
    
//    func updateWithScrollIndex(_ scrollIndex: Int) {
//        self.scrollIndex = scrollIndex
//        scrollOffset = scrollOffsetFrom(scrollIndex)
//        dialIndex = mapScrollIndexToDialIndex(scrollIndex)
//        dialOffset = mapScrollOffsetToDialOffset(scrollOffset)
//    }
//
//    func updateWithScrollOffset(_ scrollOffset: CGFloat) {
//        scrollIndex = scrollIndexFrom(scrollOffset)
//        self.scrollOffset = scrollOffset
//        dialIndex = mapScrollIndexToDialIndex(scrollIndex)
//        dialOffset = mapScrollOffsetToDialOffset(scrollOffset)
//    }
//
//    func updateWithDialIndex(_ dialIndex: Int) {
//        let scrollIndex = unmapDialIndexToScrollIndex(dialIndex)
//        updateWithScrollIndex(scrollIndex)
//    }
//
//    func updateWithDialOffset(_ dialOffset: CGFloat) {
//        let scrollOffset = unmapDialOffsetToScrollOffset(dialOffset)
//        updateWithScrollOffset(scrollOffset)
//    }
}

// MARK: private
private extension LMDialMapper {
//    func scrollOffsetFrom(_ scrollIndex: Int) -> CGFloat {
//        return CGFloat(scrollIndex) * cellInterval
//    }
//
//    func scrollIndexFrom(_ scrollOffset: CGFloat) -> Int {
//        let cloestOffset = cloestDividingLineOffsetX(from: scrollOffset)
//        let scrollIndex = Int(round(Double(cloestOffset / cellInterval)))
//        return scrollIndex
//    }
//
//    func dialOffsetFrom(_ dialIndex: Int) -> CGFloat {
//        let scrollIndex = unmapDialIndexToScrollIndex(dialIndex)
//        let scrollOffset = scrollOffsetFrom(scrollIndex)
//        let dialOffset = mapScrollOffsetToDialOffset(scrollOffset)
//        return dialOffset
//    }
//
//    func dialIndexFrom(_ dialOffset: CGFloat) -> Int {
//        let scrollOffset = unmapDialOffsetToScrollOffset(dialOffset)
//        let scrollIndex = scrollIndexFrom(scrollOffset)
//        let dialIndex = mapScrollIndexToDialIndex(scrollIndex)
//        return dialIndex
//    }
//
////    func mapScrollIndexToDialIndex(_ scrollIndex: Int) -> Int {
////        return scrollIndex - startIndex
////    }
////
////    func unmapDialIndexToScrollIndex(_ dialIndex: Int) -> Int {
////        return dialIndex + startIndex
////    }
//
//    func mapScrollOffsetToDialOffset(_ scrollOffset: CGFloat) -> CGFloat {
//        return scrollOffset - startOffsetX
//    }
//
//    func unmapDialOffsetToScrollOffset(_ dialOffset: CGFloat) -> CGFloat {
//        return dialOffset + startOffsetX
//    }
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
