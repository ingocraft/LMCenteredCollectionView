//
//  DialViewCell.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class DialViewCell: LMCenteredCollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
