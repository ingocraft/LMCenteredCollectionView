//
//  WheelViewCell.swift
//  InfiniteCollectionView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import InfiniteCollectionView

class WheelViewCell: InfiniteCollectionViewCell {
    var numberLabel: UILabel!
    var lineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        numberLabel = {
            let label = UILabel()
            label.textColor = UIColor.red
            return label
        }()
        
        lineView = {
            let view = UIView()
            return view
        }()
        
        addSubview(numberLabel)
        addSubview(lineView)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints += [
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            numberLabel.topAnchor.constraint(equalTo: topAnchor)
        ]
        
        constraints += [
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 1.0),
            lineView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
