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
    
    var isInfinite = true {
        didSet {
            updateDialInfo()
        }
    }
    var frameCount: Int = 48 {
        didSet {
            updateDialInfo()
        }
    }
    var interDividingSpace: CGFloat = 20 {
        didSet {
            updateDialInfo()
        }
    }
    var dividingSize = CGSize(width: 2, height: 24) {
        didSet {
            updateDialInfo()
        }
    }
    
    private var _cellCount: Int = 0
    private var _interSpace: CGFloat = 0
    private var _latestScrollIndex: Int = -1
//    private var _index: Int = 0
//    private var _latestScrollOffsetX: CGFloat = 0

    var startOffsetX: CGFloat = 0
    var endOffsetX: CGFloat = 0
    var viewWidth: CGFloat = 0 {
        didSet {
            updateDialInfo()
        }
    }
    
    var startIndex: Int = 0
    var endIndex: Int = 0
    var firstIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    init() {
    }
}

// MARK: internal
extension DialInfo {
    func isStartIndexPath(at indexPath: IndexPath) -> Bool {
        return (indexPath.item - startIndex) % frameCount == 0
    }
    
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
        if isInfinite {

            // calculate scroll offset
            var willScroll: Bool = false
            var offsetXScrollTo: CGFloat = scrollOffsetX
            if scrollOffsetX <= startOffsetX - _interSpace {
                willScroll = true
                offsetXScrollTo = endOffsetX
                _latestScrollIndex = endIndex + 1
            } else if scrollOffsetX >= endOffsetX + _interSpace {
                willScroll = true
                offsetXScrollTo = startOffsetX
                _latestScrollIndex = startIndex - 1
            }
            
            let latestScrollIndexOffset = transformToScrollIndexOffset(from: _latestScrollIndex)
            let floatIndex = Double((offsetXScrollTo - startOffsetX) / _interSpace + CGFloat(startIndex))
            let currScrollOffset = scrollOffsetX

            // contentOffset changes per 1/3
            // add a bias to make the check correct
            let bias: CGFloat = 1 / 3
            
            let currScrollIndex: Int
            if currScrollOffset <= latestScrollIndexOffset - _interSpace + bias {
                currScrollIndex = Int(ceil(floatIndex))
            } else if currScrollOffset >= latestScrollIndexOffset + _interSpace - bias {
                currScrollIndex = Int(floor(floatIndex))
            } else {
                currScrollIndex = _latestScrollIndex
            }

            _latestScrollIndex = currScrollIndex
            return (mapToDialIndex(from: currScrollIndex), willScroll, offsetXScrollTo)
        } else {
            return (0, false, 0)
        }
    }
    
    func indexForOffsetX(_ offsetX: CGFloat) -> Int {
        let index = Int((offsetX - startOffsetX) / _interSpace)
        return index
    }
    
    func offsetXToScroll(_ offsetX: CGFloat) -> (Bool, CGFloat) {
        let index = indexForOffsetX(offsetX) + startIndex
        var willScroll: Bool = false
        var offset: CGFloat = 0
        if index > endIndex {
            willScroll = true
            offset = startOffsetX
        } else if index < startIndex {
            willScroll = true
            offset = endOffsetX
        }
        
        return (willScroll, offset)
    }
}

private extension DialInfo {
    func updateDialInfo() {
        if isInfinite {
            let space = interDividingSpace + dividingSize.width
            _interSpace = space
            
            // calculate cell count
            /// cell's count in the given width
            let cellsInWidth = Int(ceil(viewWidth / space))
            /// add two extra cell in case `floor` decrease cell's count
            let bias = 10
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
        } else {
            // TBD
        }
        
        dialInfoUpdated?()
    }
}

private extension DialInfo {
    func mapToDialIndex(from scrollIndex: Int) -> Int {
        if (startIndex...endIndex) ~= scrollIndex {
            return scrollIndex - startIndex
        } else if scrollIndex < startIndex {
            return endIndex - (startIndex - scrollIndex) - startIndex
        } else if scrollIndex > endIndex {
            return startIndex + (scrollIndex - endIndex) - startIndex
        }
        
        return 0
    }
    
    func mapToScrollIndex(from dialIndex: Int) -> Int {
        return dialIndex + startIndex
    }
    
    func mapToDialOffset(from scrollOffset: CGFloat) -> CGFloat {
        if (startOffsetX...endOffsetX) ~= scrollOffset {
            return scrollOffset - startOffsetX
        } else if scrollOffset < startOffsetX {
            return endOffsetX - (startOffsetX - scrollOffset)
        } else if scrollOffset > endOffsetX {
            return startOffsetX + (scrollOffset - endOffsetX)
        }
        
        return 0
    }
    
    func mapToScrollOffset(from dialOffset: CGFloat) -> CGFloat {
        return dialOffset + startOffsetX
    }
    
    func transformToDialIndexOffset(from dialIndex: Int) -> CGFloat {
        return CGFloat(dialIndex) * _interSpace
    }
    
    func transformToScrollIndexOffset(from scrollIndex: Int) -> CGFloat {
        return CGFloat(scrollIndex - startIndex) * _interSpace + startOffsetX
    }
}
