//
//  WheelView.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import InfiniteCollectionView

class WheelView: UIView {
    
    private var infiniteView: LMDialView!
    
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

// MARK: LMDialViewDelegate
extension WheelView: LMDialViewDelegate {
    func interitemSpacingBetweenItems(in infiniteView: LMDialView) -> CGFloat {
        return 10
    }
    
    func sizeOfItems(in infiniteView: LMDialView) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

// MARK: LMDialViewDataSource
extension WheelView: LMDialViewDataSource {
    func numberOfItems(in infiniteView: LMDialView) -> Int {
        return 50
    }
    
    func infiniteView(_ infiniteView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
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
            let view = LMDialView()
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
