//
//  LMDialView.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

protocol SPIHorizontalWheelDelegate: class {
    
    /// Tell the delegate which index the dial has scroll to. Range from 0 to 47.
    func horizontalWheel(_ horizontalWheel: SPIHorizontalWheel, at index: Int)
    
    /// Tell the delegate when the scroll is about to start scroll the dial.
    func horizontalWheelWillBeginDragging(_ horizontalWheel: SPIHorizontalWheel)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    func horizontalWheelDidEndScroll(_ horizontalWheel: SPIHorizontalWheel)
    
    @available(*, deprecated, message: "Use `func horizontalWheel(_ horizontalWheel: SPIHorizontalWheel, at index: Int) instead")
    func horizontalWheel(_ horizontalWheel: SPIHorizontalWheel, scrollPercent: CGFloat)
}

/**
 The SPIHorizontalWheel class.
 
 This class was designed and implemented to show a dial in the display and edit scene.
 It look like a dial which can scroll circularly.
 The scales of the dial is fixed and the number of them are 48.
 
 */
class SPIHorizontalWheel: UIView {
    
    weak var delegate: SPIHorizontalWheelDelegate?
    private var isPanning = false
    private let dialInfo = DialInfo()
    
    private var collectionView: UICollectionView!

    private lazy var middleLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        return view
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let colors = [UIColor.black.withAlphaComponent(0.2).cgColor,
                      UIColor.black.withAlphaComponent(0.4).cgColor,
                      UIColor.black.withAlphaComponent(0.6).cgColor,
                      UIColor.black.withAlphaComponent(0.8).cgColor,
                      UIColor.black.withAlphaComponent(1.0).cgColor,
                      UIColor.black.withAlphaComponent(0.8).cgColor,
                      UIColor.black.withAlphaComponent(0.6).cgColor,
                      UIColor.black.withAlphaComponent(0.4).cgColor,
                      UIColor.black.withAlphaComponent(0.2).cgColor]
        
        let gradient = CAGradientLayer()
        gradient.frame = containerView.bounds
        gradient.colors = colors
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        containerView.layer.mask = gradient
        
        // collectionView's layout will be update after this function,
        // but we need the frame right now.
        layoutIfNeeded()
        
        // update viewWidth in dialInfo
        dialInfo.viewWidth = frame.width
        
        // firstIndexPath must be used after dialInfo.viewWidth is assigned,
        // or indexPath will be wrong.
        let indexPath = dialInfo.firstIndexPath
        // scrollToItem must be invoked after collectionView has finished its layout.
        // At this case, layoutIfNeed() below did this, or scrollToItem(at:, at:, animated:) is invalid.
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

// MARK: internal
extension SPIHorizontalWheel {
    /**
     Set the current contentOffset according to percent.
     
     This function does nothing if dragging or before end accelerating.
     
     - Parameters:
     - percent:from 0.0 to 1.0.
     */
    func seek(to percent: CGFloat) {
        if isPanning { return }
        
        let index = Int(CGFloat(dialInfo.frameCount) * percent)
        let space = dialInfo.minimumLineSpace + dialInfo.itemSize.width
        let startOffsetX = dialInfo.startOffsetX
        
        let offsetX = startOffsetX + CGFloat(index) * space
        let contentOffset = CGPoint(x: offsetX, y: 0)
        collectionView.contentOffset = contentOffset
    }
}

// MARK: UIScrollViewDelegate
extension SPIHorizontalWheel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let space = dialInfo.minimumLineSpace + dialInfo.itemSize.width
        let startCellOffsetX = dialInfo.startOffsetX
        let index = Int((offsetX - startCellOffsetX) / space)
        let realIndex = index + dialInfo.startIndex
        
        if realIndex > dialInfo.endIndex {
            let startOffsetX = dialInfo.startOffsetX
            scrollView.contentOffset = CGPoint(x: startOffsetX, y: 0)
            return
        } else if realIndex < dialInfo.startIndex {
            let endOffsetX = dialInfo.endOffsetX
            scrollView.contentOffset = CGPoint(x: endOffsetX, y: 0)
            return
        }
        
        delegate?.horizontalWheel(self, at: index)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPanning = true
        
        delegate?.horizontalWheelWillBeginDragging(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { return }
        
        scrollToMiddle()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToMiddle()
    }
}

// MARK: UICollectionViewDelegate
extension SPIHorizontalWheel: UICollectionViewDelegate {
    
}

// MARK: UICollectionViewDataSource
extension SPIHorizontalWheel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dialInfo.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)
        
        let isStartCell = dialInfo.isStartIndexPath(at: indexPath)
        if isStartCell {
            cell.backgroundColor = UIColor.black
        } else {
            cell.backgroundColor = UIColor.lightGray
        }
        
        
        return cell
    }
    
}

// MARK: private
private extension SPIHorizontalWheel {
    func scrollToMiddle() {
        isPanning = false
        
        let visiableCells = collectionView.visibleCells.sorted { (lhs, rhs) -> Bool in
            return lhs.frame.origin.x < rhs.frame.origin.x
        }
        let count = visiableCells.count
        let median = count / 2
        let middleCell = visiableCells[median]
        
        let contentOffset = CGPoint(x: middleCell.frame.origin.x - collectionView.frame.width / 2, y: 0)
        collectionView.setContentOffset(contentOffset, animated: true)
        
        delegate?.horizontalWheelDidEndScroll(self)
    }
}

// MARK: UI
private extension SPIHorizontalWheel {
    func setupSubviews() {
        backgroundColor = UIColor.white
        
        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = dialInfo.minimumLineSpace
            layout.itemSize = dialInfo.itemSize
            layout.scrollDirection = .horizontal
            return layout
        }()
        
        collectionView = {
            let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
            view.delegate = self
            view.dataSource = self
            view.showsHorizontalScrollIndicator = false
            view.backgroundColor = UIColor.clear
            
            return view
        }()


        addSubview(containerView)
        containerView.addSubview(collectionView)
        containerView.addSubview(middleLineView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        
        middleLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            middleLineView.widthAnchor.constraint(equalToConstant: 2.0),
            middleLineView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            middleLineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            middleLineView.heightAnchor.constraint(equalToConstant: 28),
            ])
    }
}
