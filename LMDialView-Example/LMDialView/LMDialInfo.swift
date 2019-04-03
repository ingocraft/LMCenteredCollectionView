//
//  DialInfo.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class DialInfo {
    var dialInfoUpdated: (() -> ())?
    
    var cellCount: Int {
        return _cellCount
    }
    
    var frameCount: Int = 0
    var interSpace: CGFloat = 0
    var cellWidth: CGFloat = 0
    var viewWidth: CGFloat = 0

    private var _cellCount: Int = 0
    private var _cellInterval: CGFloat = 0
    private var _latestScrollIndex: Int = -1
    private var dialMapper: LMDialMapper!

    var startOffsetX: CGFloat = 0
    var endOffsetX: CGFloat = 0

    var startIndex: Int = 0
    var endIndex: Int = 0
    var firstIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    init() {
    }
}

// MARK: internal
extension DialInfo {
    func reloadData() {
        updateDialInfo()
    }
}

// MARK: internal
extension DialInfo {
    func indexFromIndexPath(_ indexPath: IndexPath) -> Int {
        let item = indexPath.item
        if item < startIndex {
            let offset = startIndex - item
            return frameCount - offset
        } else if item > endIndex {
            let offset = item - endIndex
            return offset - 1
        } else {
            return item - startIndex
        }
    }
    
    func calculateScrollParams(scrollOffsetX: CGFloat) -> (Int, Bool, CGFloat) {
        // calculate scroll offset
        var willScroll: Bool = false
        var offsetXScrollTo: CGFloat = scrollOffsetX
        if scrollOffsetX <= startOffsetX - _cellInterval {
            willScroll = true
            offsetXScrollTo = endOffsetX
            _latestScrollIndex = endIndex + 1
        } else if scrollOffsetX >= endOffsetX + _cellInterval {
            willScroll = true
            offsetXScrollTo = startOffsetX
            _latestScrollIndex = startIndex - 1
        }
        
        let latestScrollIndexOffset = transformToScrollIndexOffset(from: _latestScrollIndex)
        let floatIndex = Double((offsetXScrollTo - startOffsetX) / _cellInterval + CGFloat(startIndex))
        let currScrollOffset = scrollOffsetX
        
        // contentOffset changes per 1/3
        // add a bias to make the check correct
        let bias: CGFloat = 1 / 3
        
        let currScrollIndex: Int
        if currScrollOffset <= latestScrollIndexOffset - _cellInterval + bias {
            currScrollIndex = Int(ceil(floatIndex))
        } else if currScrollOffset >= latestScrollIndexOffset + _cellInterval - bias {
            currScrollIndex = Int(floor(floatIndex))
        } else {
            currScrollIndex = _latestScrollIndex
        }
        
        _latestScrollIndex = currScrollIndex
        return (mapToCycleDialIndex(from: currScrollIndex), willScroll, offsetXScrollTo)
    }
    
    func cloestDividingLineOffsetX(from scrollOffsetX: CGFloat) -> CGFloat {
        let dialOffsetX = mappedDialOffset(from: scrollOffsetX)
        let prevIndex = CGFloat(floor(Double(dialOffsetX / _cellInterval)))
        let prevOffsetX = prevIndex * _cellInterval
        let nextOffsetX = prevOffsetX + _cellInterval
        let distanceToPrev = dialOffsetX - prevOffsetX
        let distanceToNext = nextOffsetX - dialOffsetX
        
        let cloestOffsetX: CGFloat
        if distanceToPrev < distanceToNext {
            cloestOffsetX = prevOffsetX
        } else {
            cloestOffsetX = nextOffsetX
        }
        
        return mappedScrollOffset(from: cloestOffsetX)
    }
}

// MARK: private
private extension DialInfo {
    func updateDialInfo() {
        let space = interSpace + cellWidth
        _cellInterval = space
        
        // calculate cell count
        /// cell's count in the given width
        let cellsInWidth = Int(ceil(viewWidth / space))
        /// add two extra cell in case `floor` decrease cell's count
        let bias = 100
        _cellCount = frameCount + cellsInWidth + bias
        
        // calculate index
        startIndex = (_cellCount - frameCount) / 2
        endIndex = ((_cellCount + frameCount) / 2) - 1
        firstIndexPath = IndexPath(item: startIndex, section: 0)
        
        // calculate offset
        let halfWidth = viewWidth / 2
        let startCellX = CGFloat(startIndex) * space
        startOffsetX = startCellX - halfWidth
        let endCellX = CGFloat(endIndex) * space
        endOffsetX = endCellX - halfWidth
        
        // latest index
        _latestScrollIndex = startIndex
        
        dialMapper = LMDialMapper(cellInterval: space, cellCount: _cellCount, cycleCount: frameCount, viewWidth: viewWidth)

        dialInfoUpdated?()
    }
    
    func indexForOffsetX(_ offsetX: CGFloat) -> Int {
        let index = Int((offsetX - startOffsetX) / _cellInterval)
        return index
    }
}

// MARK: map dial scene to cycle dial scene
private extension DialInfo {
    func mapToCycleDialIndex(from scrollIndex: Int) -> Int {
        if (startIndex...endIndex) ~= scrollIndex {
            return scrollIndex - startIndex
        } else if scrollIndex < startIndex {
            return endIndex - (startIndex - scrollIndex) - startIndex
        } else if scrollIndex > endIndex {
            return startIndex + (scrollIndex - endIndex) - startIndex
        }
        
        return 0
    }
    
    func mapToScrollIndex(from cycleDialIndex: Int) -> Int {
        return cycleDialIndex + startIndex
    }
    
    func mapToCycleDialOffset(from scrollOffset: CGFloat) -> CGFloat {
        if (startOffsetX...endOffsetX) ~= scrollOffset {
            return scrollOffset - startOffsetX
        } else if scrollOffset < startOffsetX {
            return endOffsetX - (startOffsetX - scrollOffset)
        } else if scrollOffset > endOffsetX {
            return startOffsetX + (scrollOffset - endOffsetX)
        }
        
        return 0
    }
    
    func mapToScrollOffset(from cycleDialOffset: CGFloat) -> CGFloat {
        return cycleDialOffset + startOffsetX
    }
    
    func transformToDialIndexOffset(from cycleDialIndex: Int) -> CGFloat {
        return CGFloat(cycleDialIndex) * _cellInterval
    }
    
    func transformToScrollIndexOffset(from scrollIndex: Int) -> CGFloat {
        return CGFloat(scrollIndex - startIndex) * _cellInterval + startOffsetX
    }
}

// MARK: map scroll scene to dial scene
private extension DialInfo {
    func mapScrollIndexToDialIndex(_ scrollIndex: Int) -> Int {
        return scrollIndex - startIndex
    }
    
    func mappedDialOffset(from scrollOffset: CGFloat) -> CGFloat {
        return scrollOffset - startOffsetX
    }
    
    func mappedScrollIndex(from dialIndex: Int) -> Int {
        return dialIndex + startIndex
    }
    
    func mappedScrollOffset(from dialOffset: CGFloat) -> CGFloat {
        return dialOffset + startOffsetX
    }
}
