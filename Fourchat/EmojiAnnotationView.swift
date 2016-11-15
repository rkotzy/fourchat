//
//  EmojiAnnotationView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/17/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import MapKit

class EmojiAnnotationView: MKAnnotationView {
    
    var label : UILabel!

    init(emojiAnnotation: EmojiPin, reuseIdentifier: String) {
        super.init(annotation: emojiAnnotation, reuseIdentifier: reuseIdentifier)
        
        label = UILabel(frame: CGRect(x: -30, y: -32, width: 64, height: 64))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
