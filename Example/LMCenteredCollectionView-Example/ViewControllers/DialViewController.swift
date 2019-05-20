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
    
    @IBOutlet weak var  centeredCollectionView: LMCenteredCollectionView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
        setupSubviews()
    }
}

// MARK: LMCenteredCollectionViewDelegate
extension DialViewController: LMCenteredCollectionViewDelegate {
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToOffset offset: CGFloat) {
        offsetLabel.text = "currentOffset = \(offset)"
    }
    
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToIndex index: Int) {
        indexLabel.text = "currentIndex = \(index)"
    }
    
    func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat {
        return 5
    }
    
    func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize {
        return CGSize(width: 15, height: 50)
    }
}

// MARK: LMCenteredCollectionViewDataSource
extension DialViewController: LMCenteredCollectionViewDataSource {
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
private extension DialViewController {
    func setupSubviews() {
        centeredCollectionView.delegate = self
        centeredCollectionView.dataSource = self
        let nibName = String(describing: DialViewCell.self)
        centeredCollectionView.register(UINib(nibName: nibName, bundle: nil))
    }
}


