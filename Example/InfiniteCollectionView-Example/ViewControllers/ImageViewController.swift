//
//  ImageViewController.swift
//  LMDialView-Example
//
//  Created by Liam on 2019/4/11.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import InfiniteCollectionView

class ImageViewController: UIViewController {
    
    private var randomColors = [UIColor]()
    private var animals = [String]()
    private var infiniteView: LMDialView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        generateAnimals()
        setupSubviews()

    }
    
}

extension ImageViewController: LMDialViewDelegate {
    func infiniteView(_ infiniteView: LMDialView, didScrollToIndex index: Int) {
//        print(index)
    }
    func infiniteView(_ infiniteView: LMDialView, didScrollToOffset offset: CGFloat) {
    }
    func infiniteViewWillBeginDragging(_ infiniteView: LMDialView) {
    }
    func infiniteViewDidEndScroll(_ infiniteView: LMDialView) {
    }
    
    func sizeOfItems(in infiniteView: LMDialView) -> CGSize {
        let factor: CGFloat = 64.0 / 48.0
        let width: CGFloat = 64 * 4
        let height: CGFloat = width / factor
        return CGSize(width: width, height: height)
    }
    
    func interitemSpacingBetweenItems(in infiniteView: LMDialView) -> CGFloat {
        return 10
    }
}

extension ImageViewController: LMDialViewDataSource {
    func infiniteView(_ infiniteView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell {
        guard let cell = infiniteView.dequeueReusableCell(for: index) as? LMImageCell else {
            return LMImageCell()
        }
        
        let fileName = self.animals[index] + ".jpg"
        let image = UIImage(named: fileName)
        cell.imageView.image = image
        cell.label.text = String(index)
        cell.label.sizeToFit()
        
        return cell
    }
    
    func numberOfItems(in infiniteView: LMDialView) -> Int {
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
        infiniteView = {
            let view = LMDialView(dialDirection: .horizontal)
            view.dataSource = self
            view.delegate = self
            view.register(LMImageCell.self)
            return view
        }()
        
        view.addSubview(infiniteView)
        
        infiniteView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            infiniteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infiniteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infiniteView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infiniteView.heightAnchor.constraint(equalToConstant: 200),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func initVerticalDialView() {
        infiniteView = {
            let view = LMDialView(dialDirection: .vertical)
            view.dataSource = self
            view.delegate = self
            view.register(LMImageCell.self)
            return view
        }()
        
        view.addSubview(infiniteView)

        infiniteView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            infiniteView.topAnchor.constraint(equalTo: view.topAnchor),
            infiniteView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infiniteView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infiniteView.widthAnchor.constraint(equalToConstant: 300),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
