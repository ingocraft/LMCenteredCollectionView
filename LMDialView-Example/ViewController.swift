//
//  ViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/3/7.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var dialView: SPIHorizontalWheel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dialView = SPIHorizontalWheel()
        view.addSubview(dialView)
        
        dialView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dialView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dialView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dialView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dialView.heightAnchor.constraint(equalToConstant: 48),
            ]
        NSLayoutConstraint.activate(constraints)
    }

}

