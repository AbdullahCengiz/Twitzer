//
//  TwitzCell.swift
//  twitzer
//
//  Created by abdullah cengiz on 02/12/15.
//  Copyright © 2015 abdullah cengiz. All rights reserved.
//

import Foundation

import UIKit
import SGImageCache

class TwitzCell: UITableViewCell {

    @IBOutlet var twitzProfileImageView: SGImageView!
    @IBOutlet var twitzTextLabel: UILabel!
    @IBOutlet var twitzProfileNameLabel: UILabel!
    @IBOutlet var twitzDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setValues(currentTwitz:Twitz){
        
    }
}

