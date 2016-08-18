//
//  Instructions.swift
//  Numbers
//
//  Created by Elise Hein on 16/07/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class Instructions: UIViewController {

    let instructionItems: UICollectionView

    private let reuseIdentifier = "InstructionItemCell"
    private let headerReuseIdentifier = "InstructionItemHeader"

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 50
        l.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 50, right: 0)
        return l
    }()

    private var instructionsData: NSArray? = {
        var data: NSArray? = nil

        if let path = NSBundle.mainBundle().pathForResource("instructions", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let parsed: NSDictionary

                // swiftlint:disable force_cast
                // swiftlint:disable line_length

                parsed = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

                // swiftlint:enable force_cast
                // swiftlint:enable line_length

                if let instructions: NSArray = parsed["instructions"] as? NSArray {
                    data = instructions
                }
            } catch {
                print("Error parsing json")
            }
        }

        return data
    }()

    init() {
        instructionItems = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        instructionItems.registerClass(InstructionItemCell.self,
                                       forCellWithReuseIdentifier: reuseIdentifier)

        // swiftlint:disable:next line_length
        instructionItems.registerClass(InstructionItemHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)

        super.init(nibName: nil, bundle: nil)

        title = "How to play"
        view.backgroundColor = UIColor.themeColor(.OffWhite)


        instructionItems.dataSource = self
        instructionItems.delegate = self
        instructionItems.backgroundColor = UIColor.clearColor()
        instructionItems.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)

        view.addSubview(instructionItems)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)


        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true

        navigationController?.navigationBar.tintColor = UIColor.themeColor(.OffBlack)
        let navigationTitleFont = UIFont.themeFontWithSize(14, weight: .Bold    )
        let attributes = [NSFontAttributeName: navigationTitleFont]
        navigationController?.navigationBar.titleTextAttributes = attributes

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        button.setBackgroundImage(UIImage(named: "back-arrow"), forState: .Normal)
        button.addTarget(self,
                         action: #selector(Instructions.goBack),
                         forControlEvents: .TouchUpInside)
        let backButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = backButton

        instructionItems.frame = view.bounds
    }

    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Instructions: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return instructionsData!.count
    }

    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let instructionItem = instructionsData![section] as? NSDictionary
        return instructionItem!["examples"]!.count
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                                         forIndexPath: indexPath)

        if let cell = cell as? InstructionItemCell {
            let instructionItem = instructionsData![indexPath.section] as? NSDictionary
            let example = (instructionItem!["examples"] as? NSArray)![indexPath.item]
            cell.instructionText = example["text"] as? String
            cell.detailText = example["detail"] as? String
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:

            // swiftlint:disable:next line_length
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath)

            if let headerView = headerView as? InstructionItemHeader {
                let instructionItem = instructionsData![indexPath.section] as? NSDictionary
                headerView.text = instructionItem!["title"] as? String
            }

            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension Instructions: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width, height: 120)
    }

    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {

        let instructionItem = instructionsData![section] as? NSDictionary
        let text = instructionItem!["title"] as? String
        let width = view.bounds.size.width
        let height = InstructionItemHeader.sizeOccupied(forAvailableWidth: width,
                                                        usingText: text!).height

        print("Width", width, "Height", height)
        return CGSize(width: width, height: height)
    }
}
