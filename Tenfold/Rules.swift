//
//  Rules.swift
//  Tenfold
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Rules: UIViewController {

    let sections: UICollectionView

    private let reuseIdentifier = "RuleExampleCell"
    private let headerReuseIdentifier = "RuleHeader"
    private let footerReuseIdentifier = "RulesFooter"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 90
        } else {
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 40
        }
        return l
    }()

    private static var data = JSON.initFromFile("rules")!

    init() {
        sections = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        sections.registerClass(RuleExampleCell.self,
                               forCellWithReuseIdentifier: reuseIdentifier)

        // swiftlint:disable:next line_length
        sections.registerClass(RuleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        // swiftlint:disable:next line_length
        sections.registerClass(RulesFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)

        super.init(nibName: nil, bundle: nil)

        sections.dataSource = self
        sections.delegate = self
        sections.backgroundColor = UIColor.clearColor()
        sections.pagingEnabled = true

        view.addSubview(sections)
        view.backgroundColor = UIColor.themeColor(.OffWhite)

        automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        backButton.setBackgroundImage(UIImage(named: "back-arrow"), forState: .Normal)
        backButton.addTarget(self,
                             action: #selector(Rules.goBack),
                             forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)

        sections.frame = view.bounds
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        let visibleCells = sections.visibleCells()

        for cell in visibleCells {
            if let cell = cell as? RuleExampleCell {
                cell.stopExampleLoop()
            }
        }
    }

    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }

    private func headerViewForIndexPath(indexPath: NSIndexPath) -> UICollectionReusableView {
        // swiftlint:disable:next line_length
        let headerView = sections.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath)

        if let headerView = headerView as? RuleHeader {
            let rule = Rules.data[indexPath.section]
            headerView.text = rule["title"].string
        }

        return headerView
    }

    private func contentHeight(forSectionAtIndex sectionIndex: Int) -> CGFloat {
        let headerHeight = sizeForHeaderInSection(withIndex: sectionIndex).height
        let footerHeight = sizeForFooterInSection(withIndex: sectionIndex).height
        var contentHeight = headerHeight + footerHeight

        let examples = Rules.data[sectionIndex]["examples"]

        for exampleIndex in Array(0..<examples.count) {
            contentHeight += sizeForExampleAtIndexPath(NSIndexPath(forItem: exampleIndex,
                                                                   inSection: sectionIndex)).height
        }

        // Add 50 for section top index (actually the header bottom spacing)
        contentHeight += 50

        // Add linespacing for each example - 1
        contentHeight += CGFloat(examples.count - 1) * layout.minimumLineSpacing

        return contentHeight
    }

    private func sizeForHeaderInSection(withIndex sectionIndex: Int) -> CGSize {
        let text = Rules.data[sectionIndex]["title"].string
        let width = view.bounds.size.width
        let height = RuleHeader.sizeOccupied(forAvailableWidth: width, usingText: text!).height
        return CGSize(width: width, height: height)
    }

    private func sizeForFooterInSection(withIndex sectionIndex: Int) -> CGSize {
        if sectionIndex == Rules.data.count - 1 {
            return CGSize(width: view.bounds.size.width, height: 80)
        } else {
            return CGSize.zero
        }
    }

    private func sizeForExampleAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        let example = Rules.data[indexPath.section]["examples"][indexPath.item]
        let text = example["text"].string
        let numberOfGridValues = example["values"].count

        let width = view.bounds.size.width
        let height = RuleExampleCell.sizeOccupied(forAvailableWidth: width,
                                                  usingText: text!,
                                                  numberOfGridValues: numberOfGridValues).height

        return CGSize(width: width, height: height)
    }

    private func pageInset(forSectionAtIndex sectionIndex: Int) -> CGFloat {
        let pageHeight = sections.bounds.size.height
        let sectionContentHeight = contentHeight(forSectionAtIndex: sectionIndex)
        return (pageHeight - sectionContentHeight) / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Rules: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Rules.data.count
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Rules.data[section]["examples"].count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? RuleExampleCell {
            let example = Rules.data[indexPath.section]["examples"][indexPath.item]
            cell.text = example["text"].string
            cell.gridValues = example["values"].arrayValue.map({ $0.int })
            cell.gridCrossedOutIndeces = example["crossedOut"].arrayValue.map({ $0.int! })
            cell.gridAnimationType = example["animationType"].string!

            cell.gridPairs = example["pairs"].arrayValue.map({ JSONPair in
                JSONPair.arrayValue.map({ index in index.int! })
            })
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return headerViewForIndexPath(indexPath)
        case UICollectionElementKindSectionFooter:
            // swiftlint:disable:next line_length
            return sections.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, forIndexPath: indexPath)
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension Rules: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView,
                        willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? RuleExampleCell {
            cell.prepareGrid()
            cell.playExampleLoop()
        }
    }
    func collectionView(collectionView: UICollectionView,
                        didEndDisplayingCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? RuleExampleCell {
            cell.stopExampleLoop()
        }
    }
}

extension Rules: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForExampleAtIndexPath(indexPath)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        var headerSize = sizeForHeaderInSection(withIndex: section)

        // We need overall top padding to the entire scroll view to act as the inset for
        // the first page (sectionInsets apply to the cells, not the header). A more logical way
        // of doing this would be to use contentInset, but this would mess up paging. So,
        // we add the heigh to the first header view.
        if section == 0 {
            headerSize.height += pageInset(forSectionAtIndex: 0)
        }

        return headerSize
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return sizeForFooterInSection(withIndex: section)
    }

    // We want the collectionview to page per section, but because each section has a different
    // content size, we adjust the insets so that a secion always takes up the full height of the
    // screen.
    //
    // All sections get a bottom inset which takes care of the bottom inset for the page the
    // section is on, plus the top inset of the next section. The top inset for the first page
    // is set by overall contentInsets.
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var inset = pageInset(forSectionAtIndex: section)

        if section + 1 < Rules.data.count {
            inset += pageInset(forSectionAtIndex: section + 1)
        }

        // 50 / 90
        return UIEdgeInsets(top: 50, left: 0, bottom: inset, right: 0)
    }
}
