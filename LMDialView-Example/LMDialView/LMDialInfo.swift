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
    var interDividingSpace: CGFloat = 12 {
        didSet {
            updateDialInfo()
        }
    }
    var dividingSize = CGSize(width: 1, height: 24) {
        didSet {
            updateDialInfo()
        }
    }
    
    private var _cellCount: Int = 0
    
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
}

private extension DialInfo {
    func updateDialInfo() {
        if isInfinite {
            let space = interDividingSpace + dividingSize.width
            
            // calculate cell count
            /// cell's count in the given width
            let cellsInWidth = Int(ceil(viewWidth / space))
            /// add two extra cell in case `floor` decrease cell's count
            let bias = 2
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
        } else {
            // TBD
        }
        
        dialInfoUpdated?()
    }
}
