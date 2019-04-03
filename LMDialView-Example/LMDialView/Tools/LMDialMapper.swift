//
//  LMDialMapper.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/3.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialMapper {
    var scrollIndex: Int = 0
    var scrollContentOffset: CGFloat = 0
    var dialIndex: Int = 0
    var dialContentOffset: CGFloat = 0
    
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
    func updateWithScrollIndex(_ scrollIndex: Int) {
        self.scrollIndex = scrollIndex
        scrollContentOffset = scrollContentOffsetFrom(scrollIndex)
        dialIndex = mapScrollIndexToDialIndex(scrollIndex)
        dialContentOffset = mapScrollContentOffsetToDialContentOffset(scrollContentOffset)
    }
    
    func updateWithScrollContentOffset(_ scrollContentOffset: CGFloat) {
        let scrollIndex = scrollIndexFrom(scrollContentOffset)
        updateWithScrollIndex(scrollIndex)
    }
    
    func updateWithDialIndex(_ dialIndex: Int) {
        let scrollIndex = unmapDialIndexToScrollIndex(dialIndex)
        updateWithScrollIndex(scrollIndex)
    }
    
    func updateWithDialContentOffset(_ dialContentOffset: CGFloat) {
        let scrollContentOffset = unmapDialContentOffsetToScrollContentOffset(dialContentOffset)
        let scrollIndex = scrollIndexFrom(scrollContentOffset)
        updateWithScrollIndex(scrollIndex)
    }
}

// MARK: private
private extension LMDialMapper {
    func scrollContentOffsetFrom(_ scrollIndex: Int) -> CGFloat {
        return CGFloat(scrollIndex) * cellInterval
    }
    
    func scrollIndexFrom(_ scrollContentOffset: CGFloat) -> Int {
        let cloestOffset = cloestDividingLineOffsetX(from: scrollContentOffset)
        let scrollIndex = Int(round(Double(cloestOffset / cellInterval)))
        return scrollIndex
    }
    
    func dialContentOffsetFrom(_ dialIndex: Int) -> CGFloat {
        let scrollIndex = unmapDialIndexToScrollIndex(dialIndex)
        let scrollContentOffset = scrollContentOffsetFrom(scrollIndex)
        let dialContentOffset = mapScrollContentOffsetToDialContentOffset(scrollContentOffset)
        return dialContentOffset
    }
    
    func dialIndexFrom(_ dialContentOffset: CGFloat) -> Int {
        let scrollContentOffset = unmapDialContentOffsetToScrollContentOffset(dialContentOffset)
        let scrollIndex = scrollIndexFrom(scrollContentOffset)
        let dialIndex = mapScrollIndexToDialIndex(scrollIndex)
        return dialIndex
    }
    
    func mapScrollIndexToDialIndex(_ scrollIndex: Int) -> Int {
        return scrollIndex - startIndex
    }
    
    func unmapDialIndexToScrollIndex(_ dialIndex: Int) -> Int {
        return dialIndex + startIndex
    }
    
    func mapScrollContentOffsetToDialContentOffset(_ scrollContentOffset: CGFloat) -> CGFloat {
        return scrollContentOffset - startOffsetX
    }
    
    func unmapDialContentOffsetToScrollContentOffset(_ dialContentOffset: CGFloat) -> CGFloat {
        return dialContentOffset + startOffsetX
    }
}

// MARK: utility
private extension LMDialMapper {
    func cloestDividingLineOffsetX(from scrollOffsetX: CGFloat) -> CGFloat {
        let dialOffsetX = mapScrollContentOffsetToDialContentOffset(scrollOffsetX)
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
        
        return unmapDialContentOffsetToScrollContentOffset(cloestOffsetX)
    }
}
