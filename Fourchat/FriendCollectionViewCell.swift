//
//  FriendCollectionViewCell.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/17/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import Kingfisher

class FriendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        imageView.layer.cornerRadius = kProfilePhotoSize / 2.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.shouldRasterize = true
        imageView.layer.rasterizationScale = UIScreen.main.scale
    }
        
    func setCell(checkin: Checkin) {
        
        nameLabel.text = checkin.firstName
        
        if checkin.userPhotoURL != nil {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: checkin.userPhotoURL!)
        } else {
            imageView.image = UIImage(named: "profile")
        }
    }
}
