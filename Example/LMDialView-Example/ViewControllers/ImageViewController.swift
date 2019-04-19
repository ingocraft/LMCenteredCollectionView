//
//  ImageViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/11.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMDialView

class ImageViewController: UIViewController {
    
    private var randomColors = [UIColor]()
    private var animals = [String]()
    private var dialView: LMDialView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        generateAnimals()
        setupSubviews()

    }
    
}

extension ImageViewController: LMDialViewDelegate {
    func dialView(_ dialView: LMDialView, didScrollToIndex index: Int) {
//        print(index)
    }
    func dialView(_ dialView: LMDialView, didScrollToOffset offset: CGFloat) {
    }
    func dialViewWillBeginDragging(_ dialView: LMDialView) {
    }
    func dialViewDidEndScroll(_ dialView: LMDialView) {
    }
    
    func sizeOfItems(in dialView: LMDialView) -> CGSize {
        let factor: CGFloat = 64.0 / 48.0
        let width: CGFloat = 64 * 4
        let height: CGFloat = width / factor
        return CGSize(width: width, height: height)
    }
    
    func interitemSpacingBetweenItems(in dialView: LMDialView) -> CGFloat {
        return 10
    }
}

extension ImageViewController: LMDialViewDataSource {
    func dialView(_ dialView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
        guard let cell = dialView.dequeueReusableCell(for: index) as? LMImageCell else {
            return LMImageCell()
        }
        
        let fileName = self.animals[index] + ".jpg"
        let image = UIImage(named: fileName)
        cell.imageView.image = image
        cell.label.text = String(index)
        cell.label.sizeToFit()
        
        return cell
    }
    
    func numberOfItems(in dialView: LMDialView) -> Int {
        return animals.count
    }
}

// MARK: private
private extension ImageViewController {
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
private extension ImageViewController {
    func setupSubviews() {
        initHorizontalDialView()
//        initVerticalDialView()
    }
    
    func initHorizontalDialView() {
        dialView = {
            let view = LMDialView(dialDirection: .horizontal)
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
    
    func initVerticalDialView() {
        dialView = {
            let view = LMDialView(dialDirection: .vertical)
            view.dataSource = self
            view.delegate = self
            view.register(LMImageCell.self)
            return view
        }()
        
        view.addSubview(dialView)

        dialView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            dialView.topAnchor.constraint(equalTo: view.topAnchor),
            dialView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dialView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dialView.widthAnchor.constraint(equalToConstant: 300),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
