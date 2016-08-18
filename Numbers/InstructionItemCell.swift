//
//  InstructionItemCell.swift
//  Numbers
//
//  Created by Elise Hein on 18/08/2016.
//  Copyright © 2016 Elise Hein. All rights reserved.
//

import Foundation
import UIKit

class InstructionItemCell: UICollectionViewCell {

    var instructionText: String? {
        didSet {
            if let instructionText = instructionText {
                instructionLabel.text = instructionText
            }
        }
    }

    var detailText: String? {
        didSet {
            if let detailText = detailText {
                detailLabel.text = detailText
            }
        }
    }

    private let instructionLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        instructionLabel.textAlignment = .Center
        instructionLabel.textColor = UIColor.themeColor(.OffBlack)
        instructionLabel.font = UIFont.themeFontWithSize(14)
        instructionLabel.numberOfLines = 0
        instructionLabel.backgroundColor = UIColor.redColor()

        detailLabel.textAlignment = .Center
        detailLabel.textColor = UIColor.themeColorHighlighted(.OffWhite)
        detailLabel.font = UIFont.themeFontWithSize(14)
        detailLabel.numberOfLines = 0
        detailLabel.backgroundColor = UIColor.blueColor()

        contentView.addSubview(instructionLabel)
        contentView.addSubview(detailLabel)
        contentView.backgroundColor = UIColor.grayColor()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let heightRequired: CGFloat = 100
        var instructionLabelFrame = contentView.frame
        instructionLabelFrame.size.height = heightRequired
        instructionLabel.frame = instructionLabelFrame

        detailLabel.frame = CGRect(x: 0,
                                   y: heightRequired,
                                   width: contentView.frame.size.width,
                                   height: 20)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
