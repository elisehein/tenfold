//
//  Instructions.swift
//  Numbers
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Instructions: UIViewController {

    let sections: UICollectionView

    private let reuseIdentifier = "RuleExampleCell"
    private let headerReuseIdentifier = "RuleHeader"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 50
        l.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 50, right: 0)
        return l
    }()

    override var title: String? {
        didSet {
            guard title != nil else { return }

            let label = UILabel()

            let navigationTitleFont = UIFont.themeFontWithSize(14)
            let attributes = [NSFontAttributeName: navigationTitleFont,
                              NSForegroundColorAttributeName: UIColor.themeColor(.OffBlack),
                              NSKernAttributeName: 2]

            label.attributedText = NSAttributedString(string: title!.uppercaseString,
                                                      attributes: attributes)
            label.sizeToFit()

            navigationItem.titleView = label
        }
    }

    private static var rules: JSON = {
        var data: JSON?

        if let path = NSBundle.mainBundle().pathForResource("instructions", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                data = JSON(data: jsonData)
            } catch {
                print("Error retrieving JSON data")
            }
        }

        return data!
    }()

    init() {
        sections = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        sections.registerClass(RuleExampleCell.self,
                               forCellWithReuseIdentifier: reuseIdentifier)

        // swiftlint:disable:next line_length
        sections.registerClass(RuleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        super.init(nibName: nil, bundle: nil)

        title = "How to play"

        sections.dataSource = self
        sections.delegate = self
        sections.backgroundColor = UIColor.clearColor()
        sections.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)

        view.addSubview(sections)
        view.backgroundColor = UIColor.themeColor(.OffWhite)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        backButton.setBackgroundImage(UIImage(named: "back-arrow"), forState: .Normal)
        backButton.addTarget(self,
                             action: #selector(Instructions.goBack),
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
            let rule = Instructions.rules[indexPath.section]
            headerView.text = rule["title"].string
        }

        return headerView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Instructions: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Instructions.rules.count
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Instructions.rules[section]["examples"].count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? RuleExampleCell {
            let example = Instructions.rules[indexPath.section]["examples"][indexPath.item]
            cell.text = example["text"].string
            cell.detailText = example["detail"].string
            cell.gridValues = example["values"].arrayValue.map({ $0.int })
            cell.crossedOutIndeces = example["crossedOut"].arrayValue.map({ $0.int! })
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            return headerViewForIndexPath(indexPath)
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension Instructions: UICollectionViewDelegate {
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

extension Instructions: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let example = Instructions.rules[indexPath.section]["examples"][indexPath.item]
        let text = example["text"].string
        let detailText = example["detail"].string

        let width = view.bounds.size.width
        let height = RuleExampleCell.sizeOccupied(forAvailableWidth: width,
                                                  usingText: text!,
                                                  detailText: detailText).height

        return CGSize(width: width, height: height)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let text = Instructions.rules[section]["title"].string
        let width = view.bounds.size.width
        let height = RuleHeader.sizeOccupied(forAvailableWidth: width, usingText: text!).height

        return CGSize(width: width, height: height)
    }
}
