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

// Because we want the collectionview to page, size calculations in this class
// have been pushed to the limits.
//
// We need each section to take up exactly one screen's worth of height. To
// avoid messing with section and content insets, each section's header and
// footer are sized to act as the insets themselves, with their content positioned
// to the bottom edge of their frame.

class Rules: UIViewController {

    let sections: UICollectionView

    private let reuseIdentifier = "RuleExampleCell"
    private let headerReuseIdentifier = "RuleHeader"
    private let footerReuseIdentifier = "RulesFooter"
    private let pageDownIndicatorReuseIdentifier = "PageDownIndicator"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()

        if UIDevice.current.userInterfaceIdiom == .pad {
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 90
            l.sectionInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        } else {
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 40
            l.sectionInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        }
        return l
    }()

    private static let centerOffset: CGFloat = -20

    private static var data = JSON.initFromFile("rules")!

    override var title: String? {
        didSet {
            guard title != nil else { return }

            let label = UILabel()

            let isIPad = UIDevice.current.userInterfaceIdiom == .pad

            let attributes = [NSAttributedStringKey.font: UIFont.themeFontWithSize(isIPad ? 18 : 14),
                              NSAttributedStringKey.foregroundColor: UIColor.themeColor(.offBlack),
                              NSAttributedStringKey.kern: 2.2 as AnyObject]

            label.attributedText = NSAttributedString(string: title!.uppercased(),
                                                      attributes: attributes)
            label.sizeToFit()

            navigationItem.titleView = label
        }
    }

    init() {
        sections = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        sections.register(RuleCell.self,
                               forCellWithReuseIdentifier: reuseIdentifier)

        // swiftlint:disable:next line_length
        sections.register(RuleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        // swiftlint:disable:next line_length
        sections.register(RulesFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier)

        // swiftlint:disable:next line_length
        sections.register(PageDownIndicator.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: pageDownIndicatorReuseIdentifier)

        super.init(nibName: nil, bundle: nil)

        title = "How to play"

        sections.dataSource = self
        sections.delegate = self
        sections.backgroundColor = UIColor.clear
        sections.isPagingEnabled = true

        view.addSubview(sections)
        view.backgroundColor = UIColor.themeColor(.offWhite)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        let backButton = UIButton()

        backButton.setBackgroundImage(UIImage(named: "back-arrow"), for: UIControlState())
        backButton.addTarget(self,
                             action: #selector(Rules.goBack),
                             for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem?.customView?.autoSetDimensions(to: CGSize(width: 20, height: 16))

        let infoButton = UIButton()
        infoButton.setBackgroundImage(UIImage(named: "menu-icon"), for: UIControlState())
        infoButton.addTarget(self,
                             action: #selector(Rules.showAppInfo),
                             for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem?.customView?.autoSetDimensions(to: CGSize(width: 25, height: 17))

        sections.frame = view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let visibleCells = sections.visibleCells

        for cell in visibleCells {
            if let cell = cell as? RuleCell {
                cell.stopExampleLoop()
            }
        }
    }

    @objc func showAppInfo() {
        present(AppInfoModal(), animated: true, completion: nil)
    }

    @objc func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }

    private func headerViewForIndexPath(_ indexPath: IndexPath) -> UICollectionReusableView {
        // swiftlint:disable:next line_length
        let headerView = sections.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath)

        if let headerView = headerView as? RuleHeader {
            let rule = Rules.data[indexPath.section]
            headerView.text = rule["title"].string
        }

        return headerView
    }

    private func contentHeight(forSectionAtIndex sectionIndex: Int) -> CGFloat {
        let headerHeight = sizeForHeaderInSection(withIndex: sectionIndex).height
        var contentHeight = headerHeight

        let examples = Rules.data[sectionIndex]["examples"]

        for exampleIndex in Array(0..<examples.count) {
            contentHeight += sizeForExampleAtIndexPath(IndexPath(item: exampleIndex,
                                                                   section: sectionIndex)).height
        }

        contentHeight += layout.sectionInset.top
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
        return CGSize(width: sections.bounds.size.width,
                      height: pageInset(forSectionAtIndex: sectionIndex))
    }

    private func sizeForExampleAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        let example = Rules.data[indexPath.section]["examples"][indexPath.item]
        let text = example["text"].string
        let numberOfGridValues = example["values"].count

        let width = view.bounds.size.width
        let height = RuleCell.sizeOccupied(forAvailableWidth: width,
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Rules.data.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Rules.data[section]["examples"].count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                                         for: indexPath)

        if let cell = cell as? RuleCell {
            let example = Rules.data[indexPath.section]["examples"][indexPath.item]
            cell.text = example["text"].string
            cell.detailText = example["detailText"].string
            cell.gridValues = example["values"].arrayValue.map({ $0.int })
            cell.gridCrossedOutIndeces = example["crossedOut"].arrayValue.map({ $0.int! })
            cell.gridAnimationType = RuleGridAnimationType(rawValue: example["animationType"].string!)!

            cell.gridPairs = example["pairs"].arrayValue.map({ JSONPair in
                JSONPair.arrayValue.map({ index in index.int! })
            })
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return headerViewForIndexPath(indexPath)
        case UICollectionElementKindSectionFooter:
            if indexPath.section == Rules.data.count - 1 {
                // swiftlint:disable:next line_length
                return sections.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, for: indexPath)
            } else {
                // swiftlint:disable:next line_length
                return sections.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: pageDownIndicatorReuseIdentifier, for: indexPath)
            }
        default:
            fatalError("Unexpected element kind")
        }
    }
}

extension Rules: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? RuleCell {
            cell.prepareGrid()
            cell.playExampleLoop()
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? RuleCell {
            cell.stopExampleLoop()
        }
    }
}

extension Rules: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForExampleAtIndexPath(indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        var headerSize = sizeForHeaderInSection(withIndex: section)
        headerSize.height += pageInset(forSectionAtIndex: section) + Rules.centerOffset

        return headerSize
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        var footerSize = sizeForFooterInSection(withIndex: section)
        footerSize.height -= Rules.centerOffset
        return footerSize
    }
}
