//
//  DialViewController.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/16.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class DialViewController: UIViewController {

    @IBOutlet weak var wheelView: WheelView!
    @IBOutlet weak var centeredCollectionView: LMCenteredCollectionView!
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
        setupPageSubviews()
    }
}

// MARK: LMCenteredCollectionViewDelegate
extension DialViewController: LMCenteredCollectionViewDelegate {
    func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize {
        return CGSize(width: 1, height: 20)
    }
    
    func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: LMCenteredCollectionViewDataSource
extension DialViewController: LMCenteredCollectionViewDataSource {
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, cellForItemAt index: Int) -> LMCenteredCollectionViewCell {
        let cell = centeredCollectionView.dequeueReusableCell(for: index)
        if index == 0 {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        return cell
    }
    
    func numberOfItems(in centeredCollectionView: LMCenteredCollectionView) -> Int {
        return 50
    }
}

// MARK: event response
private extension DialViewController {
    
}

// MARK: init subviews
private extension DialViewController {
    func setupPageSubviews() {
        centeredCollectionView.dataSource = self
        centeredCollectionView.delegate = self
        centeredCollectionView.register(LMCenteredCollectionViewCell.self)
    }
}
