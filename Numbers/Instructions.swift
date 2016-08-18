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

    private let reuseIdentifier = "InstructionItemCell"
    private let headerReuseIdentifier = "InstructionItemHeader"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 50
        l.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 50, right: 0)
        return l
    }()

    private static var data: JSON = {
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

        sections.registerClass(InstructionItemCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)

        // swiftlint:disable:next line_length
        sections.registerClass(InstructionItemHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        super.init(nibName: nil, bundle: nil)

        title = "HOW TO PLAY"
        view.backgroundColor = UIColor.themeColor(.OffWhite)


        sections.dataSource = self
        sections.delegate = self
        sections.backgroundColor = UIColor.clearColor()
        sections.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)

        view.addSubview(sections)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)


        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true

        navigationController?.navigationBar.tintColor = UIColor.themeColor(.OffBlack)
        let navigationTitleFont = UIFont.themeFontWithSize(14)
        let attributes = [NSFontAttributeName: navigationTitleFont]
        navigationController?.navigationBar.titleTextAttributes = attributes

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        button.setBackgroundImage(UIImage(named: "back-arrow"), forState: .Normal)
        button.addTarget(self,
                         action: #selector(Instructions.goBack),
                         forControlEvents: .TouchUpInside)
        let backButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = backButton

        sections.frame = view.bounds
    }

    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }

    private func headerViewForIndexPath(indexPath: NSIndexPath) -> UICollectionReusableView {
        // swiftlint:disable:next line_length
        let headerView = sections.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath)

        if let headerView = headerView as? InstructionItemHeader {
            let instructionItem = Instructions.data["rules"][indexPath.section]
            headerView.text = instructionItem["title"].string
        }

        return headerView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Instructions: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return Instructions.data["rules"].count
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return Instructions.data["rules"][section]["examples"].count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? InstructionItemCell {
            let example = Instructions.data["rules"][indexPath.section]["examples"][indexPath.item]
            cell.instructionText = example["text"].string
            cell.detailText = example["detail"].string
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

extension Instructions: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let example = Instructions.data["rules"][indexPath.section]["examples"][indexPath.item]
        let instructionText = example["text"].string
        let detailText = example["detail"].string

        let width = view.bounds.size.width
        let height = InstructionItemCell.sizeOccupied(forAvailableWidth: width,
                                                      usingInstructionText: instructionText!,
                                                      detailText: detailText).height

        return CGSize(width: width, height: height)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let text = Instructions.data["rules"][section]["title"].string
        let width = view.bounds.size.width
        let height = InstructionItemHeader.sizeOccupied(forAvailableWidth: width,
                                                        usingText: text!).height

        return CGSize(width: width, height: height)
    }
}
