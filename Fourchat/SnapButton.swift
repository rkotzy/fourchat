//
//  SnapButton.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

@IBDesignable
class SnapButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        let width : CGFloat = 6
        let border = UIBezierPath(ovalIn: rect.insetBy(dx: width/2, dy: width/2))
        border.lineWidth = width
        UIColor.darkGray.setStroke()
        border.stroke()
        
        let circle = UIBezierPath(ovalIn: rect.insetBy(dx: width/2, dy: width/2))
        circle.lineWidth = width-2
        UIColor.white.setStroke()
        circle.stroke()
    }
}
