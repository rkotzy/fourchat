//
//  CheckinCell.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/24/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

class CheckinCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
    }
    
    func setupCell(venue: Venue) {
        
        if let name = venue.name {
            titleLabel.text = venue.categoryEmoji + " " + name
        } else {
            titleLabel.text = venue.categoryEmoji
        }
    }

}
