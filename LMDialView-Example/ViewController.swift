//
//  ViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/3/7.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var randomColors = [UIColor]()
    private var dialView: LMDialView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRandomData()
        setupSubviews()
    }

}

extension ViewController: LMDialViewDelegate {
    func dialView(_ dialView: LMDialView, at index: Int) {
//        print(index)
    }
    func dialView(_ dialView: LMDialView, offset: CGFloat) {
        print(offset)
    }
    func dialViewWillBeginDragging(_ dialView: LMDialView) {
    }
    func dialViewDidEndScroll(_ dialView: LMDialView) {
    }
}

extension ViewController: SPIDialViewDataSource {
    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell {
        let cell = dialView.dequeueReusableCell(for: index)
        
        let isStartCell = index == 0
        if isStartCell {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func dialViewItems(_ dialView: LMDialView) -> Int {
        return 50
    }
    
    func dialViewSize(_ dialView: LMDialView) -> CGSize {
        return CGSize(width: 10, height: 20)
    }
    
    func dialViewInterSpace(_ dialView: LMDialView) -> CGFloat {
        return 20
    }
}

// MARK: private
private extension ViewController {
    func generateRandomData() {
        for _ in 0...48 {
            let red = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            let green = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            let blue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            randomColors.append(UIColor.init(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }
}

// MARK: UI
private extension ViewController {
    func setupSubviews() {
        dialView = LMDialView()
        dialView.dataSource = self
        dialView.delegate = self
        view.addSubview(dialView)
        
        dialView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dialView.heightAnchor.constraint(equalToConstant: 200),
            ]
        NSLayoutConstraint.activate(constraints)
    }
}
