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
    
    /// Tell the delegate when the user scrolls dial view within the receiver.
    func dialView(_ dialView: LMDialView, offset: CGFloat)
    
    /// Tell the delegate when the scroll is about to start scroll the dial.
    func dialViewWillBeginDragging(_ dialView: LMDialView)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    func dialViewDidEndScroll(_ dialView: LMDialView)
}

protocol SPIDialViewDataSource: class {
    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell
    func dialViewSize(_ dialView: LMDialView) -> CGSize
    func dialViewInterSpace(_ dialView: LMDialView) -> CGFloat
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
    
    var isGradual: Bool = true
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
        
        /// !!!!!! init after init() !!!!!!!
        if isGradual {
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
        }
        
        dialInfo.frameCount = 48
        dialInfo.interSpace = dataSource?.dialViewInterSpace(self) ?? 0
        dialInfo.cellWidth = dataSource?.dialViewSize(self).width ?? 0
        dialInfo.viewWidth = frame.width
        dialInfo.reloadData()
        
        // collectionView will perform `layoutSubview()` after this function,
        // `seek()` works after collectionView updates its frames
        DispatchQueue.main.async {
            self.seek(toDialIndex: 0, animated: false)
        }
    }
}

// MARK: internal
extension LMDialView {
    /// Sets the current dial index.
    ///
    /// - Parameters:
    ///   - index: The dial index.
    ///   - animated: Scroll animate.
    func seek(toDialIndex index: Int, animated: Bool = false) {
        let dialOffset = dialInfo.dialOffsetFrom(dialIndex: index)
        seek(toDialOffset: dialOffset, animated: animated)
    }
    
    /// Sets the current dial content offset.
    ///
    /// - Parameters:
    ///   - offset: The dial content offset.
    ///   - animated: Scroll animate.
    func seek(toDialOffset offset: CGFloat, animated: Bool = false) {
        if isPanning { return }
        
        let scrollOffset = dialInfo.middleScrollOffsetFrom(dialOffset: offset)
        collectionView.contentOffset = CGPoint(x: scrollOffset, y: 0)
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
        let offsetXScrollTo = dialInfo.calculateScrollOffsetFrom(scrollOffset: offsetX)
        
        let willScroll = offsetXScrollTo != offsetX
        if willScroll {
            scrollView.contentOffset = CGPoint(x: offsetXScrollTo, y: 0)
            return
        }
        
        // cycle dial offset
        let dialOffset = dialInfo.cycleDialOffsetFrom(scrollOffset: offsetXScrollTo)
        delegate?.dialView(self, offset: dialOffset)
        
        // dial index
        let index = dialInfo.calculateIndexFrom(scrollOffset: offsetXScrollTo)
        guard latestIndex != index else { return }
        latestIndex = index
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

extension LMDialView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = dataSource?.dialViewSize(self) else {
            return CGSize(width: 20, height: 20)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let interSpace = dataSource?.dialViewInterSpace(self) else {
            return 20
        }
        return interSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.greatestFiniteMagnitude
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
        
        let contentOffset = CGPoint(x: middleCell.frame.origin.x - collectionView.frame.width / 2 + dialInfo.cellWidth / 2, y: 0)
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
//            view.isHidden = true
            return view
        }()
        
        containerView = {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        }()

        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
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
