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
    @IBOutlet weak var wheelView: DialView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dial"
    }
}
