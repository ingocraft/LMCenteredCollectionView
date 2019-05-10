//
//  LMCenteredCollectionView.swift
//  LMCenteredCollectionView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

public protocol LMCenteredCollectionViewDataSource: class {
    /// Asks the data source for a cell to insert a paticular location of the collection view.
    func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, cellForItemAt index: Int) -> LMCenteredCollectionViewCell
    
    /// Tells the data source to return the number of items.
    func numberOfItems(in centeredCollectionView: LMCenteredCollectionView) -> Int
}

@objc public protocol LMCenteredCollectionViewDelegate: class {
    /// Tell the delegate which index the collection view has scroll to.
    @objc optional func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToIndex index: Int)

    /// Tell the delegate when the user scrolls collection view within the receiver.
    @objc optional func centeredCollectionView(_ centeredCollectionView: LMCenteredCollectionView, didScrollToOffset offset: CGFloat)

    /// Tell the delegate when the scroll is about to start scroll the collection view.
    @objc optional func centeredCollectionViewWillBeginDragging(_ centeredCollectionView: LMCenteredCollectionView)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    @objc optional func centeredCollectionViewDidEndScroll(_ centeredCollectionView: LMCenteredCollectionView)
    
    /// Asks the delegate for the size of the specificd item's cell.
    @objc optional func sizeOfItems(in centeredCollectionView: LMCenteredCollectionView) -> CGSize

    /// Asks the delegate for the interitem spacing between successive items.
    @objc optional func interitemSpacingBetweenItems(in centeredCollectionView: LMCenteredCollectionView) -> CGFloat
}

/**
 The LMCenteredCollectionView class.
 
 This class was designed and implemented to show a infinite centered collection view.

 */
open class LMCenteredCollectionView: UIView {
    
    public enum Direction: Int {
        case horizontal
        case vertical
    }

    // MARK: Properties
    open weak var delegate: LMCenteredCollectionViewDelegate?
    open weak var dataSource: LMCenteredCollectionViewDataSource?

    private var collectionView: UICollectionView!

    private var dialManager: LMCenteredCollectionViewManager?
    private var latestIndex: Int = -1
    
    private(set) var itemSize = CGSize(width: 50, height: 50)
    private(set) var interitemSpacing: CGFloat = 10.0

    private var cellIdentifier: String?
    private(set) var dialDirection: Direction = .horizontal
    @IBInspectable private var dialDirectionAdapter: Int {
        get {
            return dialDirection.rawValue
        }
        set {
            dialDirection = Direction(rawValue: newValue) ?? .horizontal
        }
    }

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

    /// Returns whether the user has touched the content to initiate scrolling.
    var isTracking: Bool {
        return collectionView.isTracking
    }

    /// A Boolean value that indicates whether the user has begun scrolling the content.
    var isDragging: Bool {
        return collectionView.isDragging
    }

    /// Returns whether the content is moving in the scroll view after the user lifted their finger.
    var isDecelerating: Bool {
        return collectionView.isDecelerating
    }

    var currentIndex: Int {
        return latestIndex
    }

    public init(frame: CGRect = CGRect.zero, dialDirection: Direction) {
        self.dialDirection = dialDirection
        super.init(frame: frame)
        setupSubviews()
    }
    
    required public convenience init() {
        self.init(frame: CGRect.zero, dialDirection: .horizontal)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let cycleCellCount = generateCycleCellCount() {
            let cellLength = generateItemSize()
            let interSpace = generateInteritemSpacing()
            let viewLength = generateViewLength()
            dialManager = LMCenteredCollectionViewManager(cycleCellCount: cycleCellCount, cellLength: cellLength, interSpace: interSpace, viewLength: viewLength)
        }

        // collectionView will perform `layoutSubview()` after this function,
        // `seek()` works after collectionView updates its frames
        layoutIfNeeded()
        seek(toDialIndex: 0, animated: false)
    }
}

// MARK: public
public extension LMCenteredCollectionView {
    /// Sets the current index.
    ///
    /// - Parameters:
    ///   - index: The centered collection view index.
    ///   - animated: Scroll animate.
    func seek(toDialIndex index: Int, animated: Bool = false) {
        guard let dialManager = dialManager else { return }
        let dialOffset = dialManager.dialOffsetFrom(dialIndex: index)
        seek(toDialOffset: dialOffset, animated: animated)
    }
    
    /// Sets the current content offset.
    ///
    /// - Parameters:
    ///   - offset: The centered collection view content offset.
    ///   - animated: Scroll animate.
    func seek(toDialOffset offset: CGFloat, animated: Bool = false) {
        guard let dialManager = dialManager else { return }
        let scrollOffset = dialManager.middleScrollOffsetFrom(dialOffset: offset)
        collectionView.contentOffset = assembleContentOffsetFrom(scrollOffset: scrollOffset)
    }
    
    func dequeueReusableCell(for index: Int) -> LMCenteredCollectionViewCell {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cellIdentifier = cellIdentifier,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? LMCenteredCollectionViewCell else {
            assertionFailure("Cell must be LMCenteredCollectionViewCell")
            return LMCenteredCollectionViewCell()
        }
        
        return cell
    }
    
    func register(_ cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
        cellIdentifier = identifier
    }
    
    func register(_ nib: UINib) {
        let identifier = String(describing: nib)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
        cellIdentifier = identifier
    }
}

// MARK: UICollectionViewDelegate
extension LMCenteredCollectionView: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dialManager = dialManager else { return }
        let contentOffset = scrollView.contentOffset
        let scrollOffset = disassembleContentOffset(contentOffset)
        
        // check the border of contentSize
        let beginContentOffset = dialManager.viewLength
        let endContentOffset = CGFloat(dialManager.cellCount) * (dialManager.cellLength + dialManager.interitemSpacing)
        let willCrossEndBorder = scrollOffset > endContentOffset - dialManager.viewLength
        let willCrossBeginBorder = scrollOffset < beginContentOffset
        let shouldResetContentOffset = willCrossBeginBorder || willCrossEndBorder
        if shouldResetContentOffset {
            adjustScrollViewOffsetIfNeed(in: scrollView)
            return
        }
        
        // get the right index and offset
        let dialIndex = dialManager.calculateIndexFrom(scrollOffset: scrollOffset)
        let multiple = dialIndex / dialManager.cycleCellCount
        let remainerIndex = dialIndex - dialManager.cycleCellCount * multiple

        let index: Int
        if remainerIndex >= 0 {
            index = remainerIndex
        } else {
            index = remainerIndex + dialManager.cycleCellCount
        }

        // centered collection view offset
        let dialOffset = dialManager.dialOffsetFrom(scrollOffset: scrollOffset)
        let cellDistance = dialManager.cellLength + dialManager.interitemSpacing
        let totalContentSize = cellDistance * CGFloat(dialManager.cycleCellCount)
        let remainerOffset = dialOffset - cellDistance * CGFloat(multiple)
        
        let targetOffset: CGFloat
        if remainerOffset >= 0 {
            targetOffset = remainerOffset
        } else {
            targetOffset = remainerOffset + totalContentSize
        }

        delegate?.centeredCollectionView?(self, didScrollToOffset: targetOffset)
        
        // filter reduplicated index and offset
        // dial index
        guard latestIndex != index else { return }
        latestIndex = index
        delegate?.centeredCollectionView?(self, didScrollToIndex: index)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.centeredCollectionViewWillBeginDragging?(self)
        adjustScrollViewOffsetIfNeed(in: scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { return }
        adjustScrollViewOffsetIfNeed(in: scrollView)
        correctContentOffsetAnimated()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustScrollViewOffsetIfNeed(in: scrollView)
        correctContentOffsetAnimated()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let dialManager = dialManager else { return }
        let contentOffset = targetContentOffset.pointee
        let scrollOffset = disassembleContentOffset(contentOffset)
        let cloestScrollOffset = dialManager.cloestDividingLineOffsetX(from: scrollOffset)
        targetContentOffset.pointee = assembleContentOffsetFrom(scrollOffset: cloestScrollOffset)
    }
}

// MARK: UICollectionViewDataSource
extension LMCenteredCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dialManager = dialManager else { return 0 }
        return dialManager.cellCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dialManager = dialManager else { return UICollectionViewCell() }
        
        let dialIndex = dialManager.indexFromIndexPath(indexPath)
        let cycleDialIndex = dialManager.cycleDialIndexFrom(dialIndex: dialIndex)
        guard let cell = dataSource?.centeredCollectionView(self, cellForItemAt: cycleDialIndex) else {
            assertionFailure("dataSource must not be nil")
            return UICollectionViewCell()
        }
        return cell
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension LMCenteredCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = delegate?.sizeOfItems?(in: self) else {
            return CGSize(width: 20, height: 20)
        }
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let interSpace = delegate?.interitemSpacingBetweenItems?(in: self) else {
            return 20
        }
        return interSpace
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.greatestFiniteMagnitude
    }
}

// MARK: private
private extension LMCenteredCollectionView {
    func adjustScrollViewOffsetIfNeed(in scrollView: UIScrollView) {
        guard let dialManager = dialManager else { return }
        let contentOffset = scrollView.contentOffset
        let scrollOffset = disassembleContentOffset(contentOffset)
        let offsetScrollTo = dialManager.calculateScrollOffsetFrom(scrollOffset: scrollOffset)
        
        let willScroll = offsetScrollTo != scrollOffset
        guard willScroll else { return }
        scrollView.contentOffset = assembleContentOffsetFrom(scrollOffset: offsetScrollTo)
    }
    
    func correctContentOffsetAnimated() {
        guard let dialManager = dialManager else { return }
        let current = disassembleContentOffset(collectionView.contentOffset)
        let target = dialManager.cloestDividingLineOffsetX(from: current)
        let offsetIsCorrect = current == target
        if offsetIsCorrect { return }
        let correctOffset = assembleContentOffsetFrom(scrollOffset: target)
        UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
            self?.collectionView.contentOffset = correctOffset
        }, completion: nil)
    }
    
    func assembleContentOffsetFrom(scrollOffset: CGFloat) -> CGPoint {
        let contentOffset: CGPoint
        switch dialDirection {
        case .horizontal:
            contentOffset = CGPoint(x: scrollOffset, y: 0)
        case .vertical:
            contentOffset = CGPoint(x: 0, y: scrollOffset)
        }
        return contentOffset
    }
    
    func disassembleContentOffset(_ contentOffset: CGPoint) -> CGFloat {
        let scrollOffset: CGFloat
        switch dialDirection {
        case .horizontal:
            scrollOffset = contentOffset.x
        case .vertical:
            scrollOffset = contentOffset.y
        }
        return scrollOffset
    }
    
    func generateCycleCellCount() -> Int? {
        guard let cycleCellCount = dataSource?.numberOfItems(in: self), cycleCellCount > 0 else {
            assertionFailure("dataSouce.numberOfitems(in:) must be greater than 0")
            return nil
        }
        return cycleCellCount
    }
    
    func generateViewLength() -> CGFloat {
        switch dialDirection {
        case .horizontal:
            return frame.width
        case .vertical:
            return frame.height
        }
    }
    
    func generateItemSize() -> CGFloat {
        if let size = delegate?.sizeOfItems?(in: self) {
            itemSize = size
        }
        switch dialDirection {
        case .horizontal:
            return itemSize.width
        case .vertical:
            return itemSize.height
        }
    }
    
    func generateInteritemSpacing() -> CGFloat {
        if let spacing = delegate?.interitemSpacingBetweenItems?(in: self) {
            interitemSpacing = spacing
        }
        return interitemSpacing
    }
}

// MARK: UI
private extension LMCenteredCollectionView {
    func setupSubviews() {
        backgroundColor = UIColor.white
        
        let layout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            switch dialDirection {
            case .horizontal:
                layout.scrollDirection = .horizontal
            case .vertical:
                layout.scrollDirection = .vertical
            }

            return layout
        }()
        
        collectionView = {
            let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            view.delegate = self
            view.dataSource = self
            view.scrollsToTop = false
            view.backgroundColor = UIColor.clear
            switch dialDirection {
            case .horizontal:
                view.showsHorizontalScrollIndicator = false
            case .vertical:
                view.showsVerticalScrollIndicator = false
            }

            return view
        }()

        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
}
