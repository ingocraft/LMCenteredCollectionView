//
//  DialView.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class DialView: UIView {
    
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
extension DialView: LMCenteredCollectionViewDelegate {
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToOffset offset: CGFloat) {
//        print(offset)
    }
    
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToIndex index: Int) {
//        print(index)
    }
    
    func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat {
        return 5
    }
    
    func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize {
        return CGSize(width: 15, height: 50)
    }
}

// MARK: LMCenteredCollectionViewDataSource
extension DialView: LMCenteredCollectionViewDataSource {
    func numberOfItems(in centeredCollectionView: LMCenteredCollectionView) -> Int {
        return 50
    }
    
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, cellForItemAt index: Int) -> LMCenteredCollectionViewCell {
        let cell = centeredCollectionView.dequeueReusableCell(for: index) as! DialViewCell
        
        cell.numberLabel.text = "\(index)"
        cell.numberLabel.textColor = UIColor.lightGray
        if index == 0 {
            cell.lineView.backgroundColor = UIColor.black
        } else {
            cell.lineView.backgroundColor = UIColor.lightGray
        }
        return cell
    }
}

// MARK: UI
private extension DialView {
    func setupSubviews() {
        // init
        centeredCollectionView = {
            let view = LMCenteredCollectionView()
            view.delegate = self
            view.dataSource = self
            let nibName = String(describing: DialViewCell.self)
            view.register(UINib(nibName: nibName, bundle: nil))
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
