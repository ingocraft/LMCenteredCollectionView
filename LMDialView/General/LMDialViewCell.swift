//
//  LMDialViewCell.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/3/11.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class LMDialViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: internal
extension LMDialViewCell {
    
}


