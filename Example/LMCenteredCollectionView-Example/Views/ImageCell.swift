//
//  ImageCell.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/10.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class ImageCell: LMCenteredCollectionViewCell {
    
    var imageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// MARK: UI
private extension ImageCell {
    func setupSubviews() {
        // init
        imageView = {
            let view = UIImageView()
            return view
        }()
        
        // add
        addSubview(imageView)
        
        // layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        label = UILabel()
        label.textColor = UIColor.red
        addSubview(label)
    }
}
