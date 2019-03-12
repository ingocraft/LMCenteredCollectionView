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
        dialView = LMDialView()
        dialView.dataSource = self
        dialView.delegate = self
        view.addSubview(dialView)
        
        dialView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dialView.heightAnchor.constraint(equalToConstant: 48),
            ]
        NSLayoutConstraint.activate(constraints)
        
        for _ in 0...48 {
            let red = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            let green = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            let blue = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            randomColors.append(UIColor.init(red: red, green: green, blue: blue, alpha: 1.0))
        }
    }

}

extension ViewController: LMDialViewDelegate {
    func dialView(_ dialView: LMDialView, at index: Int) {
        print(index)
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
}
