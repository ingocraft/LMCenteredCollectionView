//
//  WheelView.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/18.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMDialView

class WheelView: UIView {
    
    private var dialView: LMDialView!
    
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
    func interitemSpacingBetweenItems(in dialView: LMDialView) -> CGFloat {
        return 10
    }
    
    func sizeOfItems(in dialView: LMDialView) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}

// MARK: LMDialViewDataSource
extension WheelView: LMDialViewDataSource {
    func numberOfItems(in dialView: LMDialView) -> Int {
        return 50
    }
    
    func dialView(_ dialView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
        guard let cell = dialView.dequeueReusableCell(for: index) as? WheelViewCell else {
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
        dialView = {
            let view = LMDialView()
            view.delegate = self
            view.dataSource = self
            view.register(WheelViewCell.self)
            return view
        }()
        
        // add
        addSubview(dialView)
        
        // layout
        dialView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints += [
            dialView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dialView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dialView.topAnchor.constraint(equalTo: topAnchor),
            dialView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
