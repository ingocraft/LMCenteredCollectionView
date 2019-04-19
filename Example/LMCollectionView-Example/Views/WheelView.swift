//
//  WheelView.swift
//  InfiniteCollectionView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCollectionView

class WheelView: UIView {
    
    private var infiniteView: InfiniteCollectionView!
    
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

// MARK: InfiniteCollectionViewDelegate
extension WheelView: InfiniteCollectionViewDelegate {
    func interitemSpacingBetweenItems(in infiniteView: InfiniteCollectionView) -> CGFloat {
        return 10
    }
    
    func sizeOfItems(in infiniteView: InfiniteCollectionView) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

// MARK: InfiniteCollectionViewDataSource
extension WheelView: InfiniteCollectionViewDataSource {
    func numberOfItems(in infiniteView: InfiniteCollectionView) -> Int {
        return 50
    }
    
    func infiniteView(_ infiniteView: InfiniteCollectionView, cellForItemAt index: Int) -> InfiniteCollectionViewCell {
        guard let cell = infiniteView.dequeueReusableCell(for: index) as? WheelViewCell else {
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
        infiniteView = {
            let view = InfiniteCollectionView()
            view.delegate = self
            view.dataSource = self
            view.register(WheelViewCell.self)
            return view
        }()
        
        // add
        addSubview(infiniteView)
        
        // layout
        infiniteView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints += [
            infiniteView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infiniteView.trailingAnchor.constraint(equalTo: trailingAnchor),
            infiniteView.topAnchor.constraint(equalTo: topAnchor),
            infiniteView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
