//
//  WheelView.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class WheelView: UIView {
    
    private var centeredCollectionView: LMCenteredCollectionView!
    
    init() {
        super.init(frame: CGRect.zero)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

// MARK: LMCenteredCollectionViewDelegate
extension WheelView: LMCenteredCollectionViewDelegate {
    func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat {
        return 10
    }
    
    func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

// MARK: LMCenteredCollectionViewDataSource
extension WheelView: LMCenteredCollectionViewDataSource {
    func numberOfItems(in centeredCollectionView: LMCenteredCollectionView) -> Int {
        return 50
    }
    
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, cellForItemAt index: Int) -> LMCenteredCollectionViewCell {
        guard let cell = centeredCollectionView.dequeueReusableCell(for: index) as? WheelViewCell else {
            return WheelViewCell()
        }
        cell.numberLabel.text = "\(index)"
        cell.lineView.backgroundColor = UIColor.lightGray
        return cell
    }
}

// MARK: UI
private extension WheelView {
    func setupSubviews() {
        // init
        centeredCollectionView = {
            let view = LMCenteredCollectionView()
            view.delegate = self
            view.dataSource = self
            view.register(WheelViewCell.self)
            return view
        }()
        
        // add
        addSubview(centeredCollectionView)
        
        // layout
        centeredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints += [
            centeredCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            centeredCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            centeredCollectionView.topAnchor.constraint(equalTo: topAnchor),
            centeredCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
