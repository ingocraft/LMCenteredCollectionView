//
//  DialViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/16.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMDialView

class DialViewController: UIViewController {

    @IBOutlet weak var dialView: LMDialView!
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
        setupPageSubviews()
    }
}

// MARK: LMDialViewDelegate
extension DialViewController: LMDialViewDelegate {
    func dialViewSize(_ dialView: LMDialView) -> CGSize {
        return CGSize(width: 1, height: 20)
    }
    
    func dialViewInterSpace(_ dialView: LMDialView) -> CGFloat {
        return 20
    }
}

// MARK: LMDialViewDataSource
extension DialViewController: LMDialViewDataSource {
    func dialView(_ dialView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
        let cell = dialView.dequeueReusableCell(for: index)
        if index == 0 {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        return cell
    }
    
    func numberOfItems(in dialView: LMDialView) -> Int {
        return 50
    }
}

// MARK: event response
private extension DialViewController {
    
}

// MARK: init subviews
private extension DialViewController {
    func setupPageSubviews() {
        dialView.dataSource = self
        dialView.delegate = self
        dialView.register(LMDialViewCell.self)
    }
}
