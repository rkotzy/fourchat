//
//  CollectionViewCell.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/5/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    var venueTitleLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let upperBorder = UIView(frame: CGRect(x: 0, y: frame.height-155, width: frame.width-40, height: 4))
        upperBorder.backgroundColor = UIColor.white
        upperBorder.layer.borderWidth = 1
        upperBorder.layer.borderColor = UIColor.darkGray.cgColor
        addSubview(upperBorder)
        let lowerBorder = UIView(frame: CGRect(x: 40, y: frame.height-45, width: frame.width-40, height: 4))
        lowerBorder.backgroundColor = UIColor.white
        lowerBorder.layer.borderWidth = 1
        lowerBorder.layer.borderColor = UIColor.darkGray.cgColor
        addSubview(lowerBorder)
        
        venueTitleLabel = UILabel(frame: CGRect(x: 12, y: frame.height-145, width: frame.width-24, height: 100))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView(withVenue: Venue) {
        
        venueTitleLabel.numberOfLines = 3
        venueTitleLabel.font = UIFont(name: "NeutraDisp-Titling", size: 32)
        venueTitleLabel.textColor = UIColor.white
        venueTitleLabel.shadowColor = UIColor.darkGray
        venueTitleLabel.shadowOffset = CGSize(width: 1, height: 1)
        venueTitleLabel.text = (withVenue.name ?? "") + " " + (withVenue.categoryEmoji ?? "")
        addSubview(venueTitleLabel)
        
    }

}
