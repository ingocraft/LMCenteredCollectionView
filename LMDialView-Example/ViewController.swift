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
    private var animals = [String]()
    private var dialView: LMDialView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateAnimals()
        setupSubviews()
    }

}

extension ViewController: LMDialViewDelegate {
    func dialView(_ dialView: LMDialView, at index: Int) {
//        print(index)
    }
    func dialView(_ dialView: LMDialView, offset: CGFloat) {
//        print(offset)
    }
    func dialViewWillBeginDragging(_ dialView: LMDialView) {
    }
    func dialViewDidEndScroll(_ dialView: LMDialView) {
    }
}

extension ViewController: SPIDialViewDataSource {
    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell {
        guard let cell = dialView.dequeueReusableCell(for: index) as? LMImageCell else {
            return LMImageCell()
        }
        
        let filePath = Bundle.main.path(forResource: animals[index], ofType: "jpg")!
        let image = UIImage(contentsOfFile: filePath)
        cell.imageView.image = image
        cell.label.text = String(index)
        cell.label.sizeToFit()

        return cell
    }
    
    func dialViewItems(_ dialView: LMDialView) -> Int {
        return animals.count
    }
    
    func dialViewSize(_ dialView: LMDialView) -> CGSize {
        return CGSize(width: 64 * 2, height: 48 * 2)
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
    
    func generateAnimals() {
        for index in 0...40 {
            let fileName = String(format: "pic1%02d", index)
            animals.append(fileName)
        }
    }
    
    func test() {
        for index in 0...40 {
            let fileName = String(format: "pic1%02d", index)
            let filePath = Bundle.main.path(forResource: fileName, ofType: "jpg")!
            let _ = UIImage(contentsOfFile: filePath)
        }
    }
}

// MARK: UI
private extension ViewController {
    func setupSubviews() {
        dialView = {
            let view = LMDialView()
            view.dataSource = self
            view.delegate = self
            view.register(LMImageCell.self)
            return view
        }()
        
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
