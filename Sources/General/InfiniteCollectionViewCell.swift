//
//  InfiniteCollectionViewCell.swift
//  InfiniteCollectionView-Example
//
//  Created by Liam on 2019/3/11.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

open class InfiniteCollectionViewCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required convenience public init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: internal
extension InfiniteCollectionViewCell {
    
}


