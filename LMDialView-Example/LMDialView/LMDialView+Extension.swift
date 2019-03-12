//
//  LMDialView+Extension.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

extension LMDialView {
    class DialInfo {
        let cellCount = 100
        let frameCount = 48
        let minimumLineSpace: CGFloat = 12
        let itemSize = CGSize(width: 1, height: 24)
        
        var startOffsetX: CGFloat = 0
        var endOffsetX: CGFloat = 0
        var viewWidth: CGFloat = 0 {
            didSet {
                let space = minimumLineSpace + itemSize.width
                let halfWidth = viewWidth / 2
                
                let startCellX = CGFloat(startIndex) * space
                startOffsetX = startCellX - halfWidth
                
                let endCellX = CGFloat(endIndex) * space
                endOffsetX = endCellX - halfWidth
            }
        }
        
        let startIndex: Int
        let endIndex: Int
        let firstIndexPath: IndexPath
        init() {
            startIndex = (cellCount - frameCount) / 2
            endIndex = ((cellCount + frameCount) / 2) - 1
            firstIndexPath = IndexPath(item: startIndex, section: 0)
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
}

