//
//  DialViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/16.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import InfiniteCollectionView

class DialViewController: UIViewController {

    @IBOutlet weak var wheelView: WheelView!
    @IBOutlet weak var infiniteView: LMDialView!
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
        setupPageSubviews()
    }
}

// MARK: LMDialViewDelegate
extension DialViewController: LMDialViewDelegate {
    func sizeOfItems(in infiniteView: LMDialView) -> CGSize {
        return CGSize(width: 1, height: 20)
    }
    
    func interitemSpacingBetweenItems(in infiniteView: LMDialView) -> CGFloat {
        return 20
    }
}

// MARK: LMDialViewDataSource
extension DialViewController: LMDialViewDataSource {
    func infiniteView(_ infiniteView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
        let cell = infiniteView.dequeueReusableCell(for: index)
        if index == 0 {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        return cell
    }
    
    func numberOfItems(in infiniteView: LMDialView) -> Int {
        return 50
    }
}

// MARK: event response
private extension DialViewController {
    
}

// MARK: init subviews
private extension DialViewController {
    func setupPageSubviews() {
        infiniteView.dataSource = self
        infiniteView.delegate = self
        infiniteView.register(LMDialViewCell.self)
    }
}
