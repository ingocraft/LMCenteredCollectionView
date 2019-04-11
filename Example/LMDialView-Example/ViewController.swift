//
//  ViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/3/7.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMDialView

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
//    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell {
//        guard let cell = dialView.dequeueReusableCell(for: index) as? LMImageCell else {
//            return LMImageCell()
//        }
//
//        if index == 0 {
//            cell.backgroundColor = UIColor.black
//        } else {
//            cell.backgroundColor = UIColor.lightGray
//        }
//
//        return cell
//    }
//
//    func dialViewItems(_ dialView: LMDialView) -> Int {
//        return 50
//    }
//
//    func dialViewSize(_ dialView: LMDialView) -> CGSize {
//        return CGSize(width: 200, height: 48)
//    }
//
//    func dialViewInterSpace(_ dialView: LMDialView) -> CGFloat {
//        return 20
//    }

    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell {
        guard let cell = dialView.dequeueReusableCell(for: index) as? LMImageCell else {
            return LMImageCell()
        }

        DispatchQueue.global().async {
            let fileName = self.animals[index] + ".jpg"
            let image = UIImage(named: fileName)
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }
        cell.label.text = String(index)
        cell.label.sizeToFit()

        return cell
    }

    func dialViewItems(_ dialView: LMDialView) -> Int {
        return animals.count
    }

    func dialViewSize(_ dialView: LMDialView) -> CGSize {
        let factor: CGFloat = 64.0 / 48.0
        let width: CGFloat = 64 * 4
        let height: CGFloat = width / factor
        return CGSize(width: width, height: height)
    }

    func dialViewInterSpace(_ dialView: LMDialView) -> CGFloat {
        return 10
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
