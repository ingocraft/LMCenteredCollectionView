//
//  DialViewController.swift
//  InfiniteCollectionView-Example
//
//  Created by Liam on 2019/4/16.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class DialViewController: UIViewController {

    @IBOutlet weak var wheelView: WheelView!
    @IBOutlet weak var infiniteView: InfiniteCollectionView!
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
        setupPageSubviews()
    }
}

// MARK: InfiniteCollectionViewDelegate
extension DialViewController: InfiniteCollectionViewDelegate {
    func sizeOfItems(in infiniteView: InfiniteCollectionView) -> CGSize {
        return CGSize(width: 1, height: 20)
    }
    
    func interitemSpacingBetweenItems(in infiniteView: InfiniteCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: InfiniteCollectionViewDataSource
extension DialViewController: InfiniteCollectionViewDataSource {
    func infiniteView(_ infiniteView: InfiniteCollectionView, cellForItemAt index: Int) -> InfiniteCollectionViewCell {
        let cell = infiniteView.dequeueReusableCell(for: index)
        if index == 0 {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        return cell
    }
    
    func numberOfItems(in infiniteView: InfiniteCollectionView) -> Int {
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
        infiniteView.register(InfiniteCollectionViewCell.self)
    }
}
