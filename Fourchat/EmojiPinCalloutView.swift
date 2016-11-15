//
//  EmojiPinCalloutView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/18/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

class EmojiPinCalloutView: UIView {

    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var venueTextLabel: UILabel!
    @IBOutlet weak var shoutTextLabel: UILabel!
    @IBOutlet weak var shoutTextLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    func setWith(annotation: EmojiPin) {
        
        layer.cornerRadius = 8
        shoutTextLabel.frame.size.width = 240
        
        nameTextLabel.text = annotation.subtitle
        venueTextLabel.text = annotation.title
        shoutTextLabel.text = annotation.shout
        shoutTextLabelHeight.constant = shoutTextLabel.requiredHeight()
                
        if annotation.photoURL != nil {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: annotation.photoURL!)
            self.frame.size.height = 41 + 150 + shoutTextLabelHeight.constant
        } else {
            self.frame.size.height = 41 + shoutTextLabelHeight.constant
        }
    }

}

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        if self.text == nil || self.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0 {
            return 0
        }
        
        let label : UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 100))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
                
        return min(label.frame.height, 100)
    }
}
