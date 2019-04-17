//
//  LMDialView.swift
//  LMDialView
//
//  Created by Liam on 2019/3/5.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

public protocol LMDialViewDataSource: class {
    /// Asks the data source for a cell to insert a paticular location of the dial view.
    func dialView(_ dialView: LMDialView, cellForItemAt index: Int) -> LMDialViewCell
    
    /// Tells the data source to return the number of items.
    func numberOfItems(in dialView: LMDialView) -> Int
}

@objc public protocol LMDialViewDelegate: class {
    /// Tell the delegate which index the dial has scroll to.
    @objc optional func dialView(_ dialView: LMDialView, didScrollToIndex index: Int)

    /// Tell the delegate when the user scrolls dial view within the receiver.
    @objc optional func dialView(_ dialView: LMDialView, didScrollToOffset offset: CGFloat)

    /// Tell the delegate when the scroll is about to start scroll the dial.
    @objc optional func dialViewWillBeginDragging(_ dialView: LMDialView)
    
    /// Tell the delegate when the scroll stops scrolling completely.
    @objc optional func dialViewDidEndScroll(_ dialView: LMDialView)
    
    /// Asks the delegate for the size of the specificd item's cell.
    @objc optional func sizeOfItems(in dialView: LMDialView) -> CGSize

    /// Asks the delegate for the interitem spacing between successive items.
    @objc optional func interitemSpacingBetweenItems(in dialView: LMDialView) -> CGFloat
}

/**
 The LMDialView class.
 
 This class was designed and implemented to show a dial in the display and edit scene.
 It look like a dial which can scroll circularly.
 The scales of the dial is fixed and the number of them are 48.
 
 */
open class LMDialView: UIView {
    
    public enum DialDirection: Int {
        case horizontal
        case vertical
    }

    // MARK: Properties
    open weak var delegate: LMDialViewDelegate?
    open weak var dataSource: LMDialViewDataSource?

    private var collectionView: UICollectionView!

    private var dialManager: LMDialManager?
    private var latestIndex: Int = -1
    
    private(set) var itemSize = CGSize(width: 50, height: 50)
    private(set) var interitemSpacing: CGFloat = 10.0

    private var cellClass: AnyClass?
    private(set) var dialDirection: DialDirection = .horizontal
    @IBInspectable private var dialDirectionAdapter: Int {
        get {
            return dialDirection.rawValue
        }
        set {
            dialDirection = DialDirection(rawValue: newValue) ?? .horizontal
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

    public init(frame: CGRect = CGRect.zero, dialDirection: DialDirection) {
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
            dialManager = LMDialManager(cycleCellCount: cycleCellCount, cellLength: cellLength, interSpace: interSpace, viewLength: viewLength)
        }

        // collectionView will perform `layoutSubview()` after this function,
        // `seek()` works after collectionView updates its frames
        layoutIfNeeded()
        seek(toDialIndex: 0, animated: false)
    }
}

// MARK: public
public extension LMDialView {
    /// Sets the current dial index.
    ///
    /// - Parameters:
    ///   - index: The dial index.
    ///   - animated: Scroll animate.
    func seek(toDialIndex index: Int, animated: Bool = false) {
        guard let dialManager = dialManager else { return }
        let dialOffset = dialManager.dialOffsetFrom(dialIndex: index)
        seek(toDialOffset: dialOffset, animated: animated)
    }
    
    /// Sets the current dial content offset.
    ///
    /// - Parameters:
    ///   - offset: The dial content offset.
    ///   - animated: Scroll animate.
    func seek(toDialOffset offset: CGFloat, animated: Bool = false) {
        guard let dialManager = dialManager else { return }
        let scrollOffset = dialManager.middleScrollOffsetFrom(dialOffset: offset)
        collectionView.contentOffset = assembleContentOffsetFrom(scrollOffset: scrollOffset)
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

// MARK: UICollectionViewDelegate
extension LMDialView: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let dialManager = dialManager else { return }
        let contentOffset = scrollView.contentOffset
        let scrollOffset = disassembleContentOffset(contentOffset)
        let offsetScrollTo = dialManager.calculateScrollOffsetFrom(scrollOffset: scrollOffset)
        
        let willScroll = offsetScrollTo != scrollOffset
        if willScroll {
            scrollView.contentOffset = assembleContentOffsetFrom(scrollOffset: offsetScrollTo)
            return
        }
        
        // cycle dial offset
        let dialOffset = dialManager.cycleDialOffsetFrom(scrollOffset: offsetScrollTo)
        delegate?.dialView?(self, didScrollToOffset: dialOffset)
        
        // dial index
        let index = dialManager.calculateIndexFrom(scrollOffset: offsetScrollTo)
        guard latestIndex != index else { return }
        latestIndex = index
        delegate?.dialView?(self, didScrollToIndex: index)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.dialViewWillBeginDragging?(self)
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
extension LMDialView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dialManager = dialManager else { return 0 }
        return dialManager.cellCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellClass = cellClass as? LMDialViewCell.Type else {
            assertionFailure("cell must be registed")
            return UICollectionViewCell()
        }
        guard let dialManager = dialManager else { return cellClass.init() }
        
        let dialIndex = dialManager.indexFromIndexPath(indexPath)
        let cycleDialIndex = dialManager.cycleDialIndexFrom(dialIndex: dialIndex)
        guard let cell = dataSource?.dialView(self, cellForItemAt: cycleDialIndex) else {
            assertionFailure("dataSource must not be nil")
            return cellClass.init()
        }
        return cell
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension LMDialView: UICollectionViewDelegateFlowLayout {
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
private extension LMDialView {
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
private extension LMDialView {
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
            switch dialDirection {
            case .horizontal:
                view.showsHorizontalScrollIndicator = false
            case .vertical:
                view.showsVerticalScrollIndicator = false
            }
            view.backgroundColor = UIColor.clear

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
