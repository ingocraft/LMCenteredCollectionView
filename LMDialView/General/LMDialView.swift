//
//  LMDialView.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

@objc protocol LMDialViewDelegate: class {
    
    /// Tell the delegate which index the dial has scroll to. Range from 0 to 47.
    @objc optional func dialView(_ dialView: LMDialView, at index: Int)
    
    /// Tell the delegate when the user scrolls dial view within the receiver.
    @objc optional func dialView(_ dialView: LMDialView, offset: CGFloat)
    
    /// Tell the delegate when the scroll is about to start scroll the dial.
    @objc optional func dialViewWillBeginDragging(_ dialView: LMDialView)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    @objc optional func dialViewDidEndScroll(_ dialView: LMDialView)
}

protocol SPIDialViewDataSource: class {
    func dialView(_ dialView: LMDialView, scaleAt index: Int) -> LMDialViewCell
    func dialViewItems(_ dialView: LMDialView) -> Int
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
    private lazy var dialManager = LMDialManager()

    private var collectionView: UICollectionView!
    private var indicatorLineView: UIView!
    private var containerView: UIView!
    private var latestIndex: Int = -1
    
    private var cellClass: AnyClass?
    
    var isGradient: Bool = false
    
    var bounces: Bool = true {
        didSet {
            collectionView.bounces = bounces
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
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
    
    var currentIndex: Int {
        return latestIndex
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
        
        if isGradient {
            gradientContainerView()
        }
        
        let cycleCellCount = dataSource?.dialViewItems(self) ?? 0
        let cellWidth = dataSource?.dialViewSize(self).width ?? 0
        let interSpace = dataSource?.dialViewInterSpace(self) ?? 0
        let viewWidth = frame.width
        dialManager.update(cycleCellCount: cycleCellCount, cellWidth: cellWidth, interSpace: interSpace, viewWidth: viewWidth)

        // collectionView will perform `layoutSubview()` after this function,
        // `seek()` works after collectionView updates its frames
        layoutIfNeeded()
        seek(toDialIndex: 0, animated: false)
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
        let dialOffset = dialManager.dialOffsetFrom(dialIndex: index)
        seek(toDialOffset: dialOffset, animated: animated)
    }
    
    /// Sets the current dial content offset.
    ///
    /// - Parameters:
    ///   - offset: The dial content offset.
    ///   - animated: Scroll animate.
    func seek(toDialOffset offset: CGFloat, animated: Bool = false) {
        let scrollOffset = dialManager.middleScrollOffsetFrom(dialOffset: offset)
        collectionView.contentOffset = CGPoint(x: scrollOffset, y: 0)
    }
    
    func dequeueReusableCell(for index: Int) -> LMDialViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cellClass = cellClass,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as? LMDialViewCell else {
            assertionFailure("Cell must be LMDialViewCell")
            return LMDialViewCell()
        }
        
        return cell
    }
    
    func register(_ cellClass: AnyClass) {
        self.cellClass = cellClass
        let identifier = String(describing: cellClass)
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
}

// MARK: UIScrollViewDelegate
extension LMDialView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let offsetXScrollTo = dialManager.calculateScrollOffsetFrom(scrollOffset: offsetX)

        let willScroll = offsetXScrollTo != offsetX
        if willScroll {
            scrollView.contentOffset = CGPoint(x: offsetXScrollTo, y: 0)
            return
        }

        // cycle dial offset
        let dialOffset = dialManager.cycleDialOffsetFrom(scrollOffset: offsetXScrollTo)
        delegate?.dialView?(self, offset: dialOffset)

        // dial index
        let index = dialManager.calculateIndexFrom(scrollOffset: offsetXScrollTo)
        guard latestIndex != index else { return }
        latestIndex = index
        delegate?.dialView?(self, at: index)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.dialViewWillBeginDragging?(self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollOffset = targetContentOffset.pointee.x
        let cloestScrollOffset = dialManager.cloestDividingLineOffsetX(from: scrollOffset)
        targetContentOffset.pointee.x = cloestScrollOffset
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
        return dialManager.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dialIndex = dialManager.indexFromIndexPath(indexPath)
        let cycleDialIndex = dialManager.cycleDialIndexFrom(dialIndex: dialIndex)
        guard let cell = dataSource?.dialView(self, scaleAt: cycleDialIndex) else {
            assertionFailure("dataSource must not be nil")
            return LMDialViewCell()
        }
        return cell
    }
    
}

// MARK: private
private extension LMDialView {
    func gradientContainerView() {
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
