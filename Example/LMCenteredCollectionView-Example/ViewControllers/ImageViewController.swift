//
//  ImageViewController.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/4/11.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit
import LMCenteredCollectionView

class ImageViewController: UIViewController {
    
    private var randomColors = [UIColor]()
    private var animals = [String]()
    private var centeredConstraints = [NSLayoutConstraint]()

    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var centeredCollectionView: LMCenteredCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Images"
        generateAnimals()
        setupSubviews()
    }
}

extension ImageViewController: LMCenteredCollectionViewDelegate {
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToIndex index: Int) {
//        print(index)
    }
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToOffset offset: CGFloat) {
    }
    func centeredCollectionViewWillBeginDragging(_ centeredCollectionView: LMCenteredCollectionView) {
    }
    func centeredCollectionViewDidEndScroll(_ centeredCollectionView: LMCenteredCollectionView) {
    }
    
    func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize {
        let factor: CGFloat = 64.0 / 48.0
        let width: CGFloat = 64 * 4
        let height: CGFloat = width / factor
        return CGSize(width: width, height: height)
    }
    
    func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat {
        return 10
    }
}

extension ImageViewController: LMCenteredCollectionViewDataSource {
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, cellForItemAt index: Int) -> LMCenteredCollectionViewCell {
        guard let cell = centeredCollectionView.dequeueReusableCell(for: index) as? ImageCell else {
            return ImageCell()
        }
        
        let fileName = self.animals[index] + ".jpg"
        let image = UIImage(named: fileName)
        cell.imageView.image = image
        cell.label.text = String(index)
        cell.label.sizeToFit()
        
        return cell
    }
    
    func numberOfItems(in centeredCollectionView: LMCenteredCollectionView) -> Int {
        return animals.count
    }
}

// MARK: event response
private extension ImageViewController {
    @IBAction func switchAction(_ sender: Any) {
        if centeredCollectionView.dialDirection == .horizontal {
            layoutVertical()
        } else {
            layoutHorizontal()
        }
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
        initDialView()
        layoutHorizontal()
    }
    
    func layoutHorizontal() {
        centeredCollectionView.dialDirection = .horizontal
        if centeredConstraints.count > 0 {
            NSLayoutConstraint.deactivate(centeredConstraints)
            centeredConstraints.forEach {
                centeredCollectionView.removeConstraint($0)
            }
        }

        centeredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centeredCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            centeredCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            centeredCollectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centeredCollectionView.heightAnchor.constraint(equalToConstant: 200),
        ]
        NSLayoutConstraint.activate(constraints)
        centeredConstraints = constraints
    }
    
    func layoutVertical() {
        centeredCollectionView.dialDirection = .vertical
        
        if centeredConstraints.count > 0 {
            NSLayoutConstraint.deactivate(centeredConstraints)
            centeredConstraints.forEach {
                centeredCollectionView.removeConstraint($0)
            }
        }

        centeredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centeredCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            centeredCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            centeredCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredCollectionView.widthAnchor.constraint(equalToConstant: 300),
        ]
        NSLayoutConstraint.activate(constraints)
        centeredConstraints = constraints
    }
    
    func initDialView() {
        centeredCollectionView.dataSource = self
        centeredCollectionView.delegate = self
        centeredCollectionView.register(ImageCell.self)
    }
}
