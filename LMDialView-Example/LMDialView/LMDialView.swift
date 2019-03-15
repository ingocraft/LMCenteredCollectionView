//
//  LMDialView.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

protocol LMDialViewDelegate: class {
    
    /// Tell the delegate which index the dial has scroll to. Range from 0 to 47.
    func dialView(_ dialView: LMDialView, at index: Int)
    
    /// Tell the delegate when the scroll is about to start scroll the dial.
    func dialViewWillBeginDragging(_ dialView: LMDialView)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    func dialViewDidEndScroll(_ dialView: LMDialView)
}

protocol SPIDialViewDataSource: class {
    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell
}

/**
 The LMDialView class.
 
 This class was designed and implemented to show a dial in the display and edit scene.
 It look like a dial which can scroll circularly.
 The scales of the dial is fixed and the number of them are 48.
 
 */
class LMDialView: UIView {
    
    // MARK: Properties
    
    weak var delegate: LMDialViewDelegate?
    weak var dataSource: SPIDialViewDataSource?
    private var isPanning = false
    private lazy var dialInfo: DialInfo = {
        let dialInfo = DialInfo()
        dialInfo.dialInfoUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        return dialInfo
    }()
    
    private var collectionView: UICollectionView!
    private var indicatorLineView: UIView!
    private var containerView: UIView!
    private var latestIndex: Int = -1
    
    var bounces: Bool = true {
        didSet {
            collectionView.bounces = bounces
        }
    }
    
    var dividingCount: Int {
        get {
            return dialInfo.frameCount
        }
        set {
            dialInfo.frameCount = newValue
        }
    }
    
    var isGradual: Bool = true {
        didSet {
            
        }
    }
    
    var isCycle: Bool = false {
        didSet {
            
        }
    }
    
    var indicatorHeight: CGFloat = 0 {
        didSet {
            
        }
    }
    
    var indicatorColor: UIColor = UIColor.clear {
        didSet {
            
        }
    }

    var dividingLineHeight: CGFloat = 0 {
        didSet {
            
        }
    }
    
    var dividingLineColor: UIColor = UIColor.clear {
        didSet {
            
        }
    }
    
    var interSpace: CGFloat = 0 {
        didSet {
            
        }
    }
    
    var isInfiniteScrollEnabled: Bool = true {
        didSet {
            
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            
        }
    }
    
    var isTracking: Bool {
        return collectionView.isTracking
    }
    
    var isDragging: Bool {
        return collectionView.isDragging
    }
    
    var isDecelerating: Bool {
        return collectionView.isDecelerating
    }
    
    var dividingLineCount: Int {
        return 0
    }
    
    var currentIndex: Int {
        return 0
    }
    
    
    
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
extension LMDialView {
    /**
     Set the current contentOffset according to percent.
     
     This function does nothing if dragging or before end accelerating.
     
     - Parameters:
     - percent:from 0.0 to 1.0.
     */
    func seek(to percent: CGFloat) {
        if isPanning { return }
        
        let index = Int(CGFloat(dialInfo.frameCount) * percent)
        let space = dialInfo.interDividingSpace + dialInfo.dividingSize.width
        let startOffsetX = dialInfo.startOffsetX
        
        let offsetX = startOffsetX + CGFloat(index) * space
        let contentOffset = CGPoint(x: offsetX, y: 0)
        collectionView.contentOffset = contentOffset
    }
    
    func dequeueReusableCell(for index: Int) -> LMDialViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LMDialViewCell.self), for: IndexPath(item: index, section: 0)) as? LMDialViewCell else {
            assertionFailure("Cell must be LMDialViewCell")
            return LMDialViewCell()
        }
        return cell
    }
}

// MARK: UIScrollViewDelegate
extension LMDialView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let space = dialInfo.interDividingSpace + dialInfo.dividingSize.width
        let startCellOffsetX = dialInfo.startOffsetX
        let index = Int((offsetX - startCellOffsetX) / space)
        let realIndex = index + dialInfo.startIndex
        
        if latestIndex == index { return }
        latestIndex = index
        
        if realIndex > dialInfo.endIndex {
            let startOffsetX = dialInfo.startOffsetX
            scrollView.contentOffset = CGPoint(x: startOffsetX, y: 0)
            return
        } else if realIndex < dialInfo.startIndex {
            let endOffsetX = dialInfo.endOffsetX
            scrollView.contentOffset = CGPoint(x: endOffsetX, y: 0)
            return
        }
        
        delegate?.dialView(self, at: index)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPanning = true
        
        delegate?.dialViewWillBeginDragging(self)
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
extension LMDialView: UICollectionViewDelegate {
    
}

// MARK: UICollectionViewDataSource
extension LMDialView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dialInfo.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = dialInfo.indexFromIndexPath(indexPath)
        guard let cell = dataSource?.dialView(self, scaleAt: index) else {
            assertionFailure("dataSource must not be nil")
            return LMDialViewCell()
        }
        return cell
    }
    
}

// MARK: private
private extension LMDialView {
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
        
        delegate?.dialViewDidEndScroll(self)
    }
}

// MARK: UI
private extension LMDialView {
    func setupSubviews() {
        backgroundColor = UIColor.white
        
        indicatorLineView = {
            let view = UIView()
            view.backgroundColor = UIColor.black
            return view
        }()
        
        containerView = {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        }()

        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = dialInfo.interDividingSpace
            layout.itemSize = dialInfo.dividingSize
            layout.scrollDirection = .horizontal
            return layout
        }()
        
        collectionView = {
            let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            view.register(LMDialViewCell.self, forCellWithReuseIdentifier: String(describing: LMDialViewCell.self))
            view.delegate = self
            view.dataSource = self
            view.showsHorizontalScrollIndicator = false
            view.backgroundColor = UIColor.clear
            
            return view
        }()

        addSubview(containerView)
        containerView.addSubview(collectionView)
        containerView.addSubview(indicatorLineView)
        
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
        
        indicatorLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorLineView.widthAnchor.constraint(equalToConstant: 2.0),
            indicatorLineView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            indicatorLineView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indicatorLineView.heightAnchor.constraint(equalToConstant: 28),
            ])
    }
}
