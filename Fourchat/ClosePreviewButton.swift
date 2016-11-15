//
//  ClosePreviewButton.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/24/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

@IBDesignable
class ClosePreviewButton: UIButton {

    override func draw(_ rect: CGRect) {
        
        let xThickness : CGFloat = 2.0
        let xMargin : CGFloat = 10.0
        
        //create the shadow path
        let xPath = UIBezierPath()
        xPath.lineCapStyle = .round
        xPath.lineWidth = xThickness + 1
        
        xPath.move(to: CGPoint(
            x:xMargin,
            y:xMargin))
        xPath.addLine(to: CGPoint(
            x:bounds.width-xMargin,
            y:bounds.height-xMargin))
        
        xPath.move(to: CGPoint(
            x:bounds.width-xMargin,
            y:xMargin))
        xPath.addLine(to: CGPoint(
            x:xMargin,
            y:bounds.height-xMargin))
        
        UIColor.gray.setStroke()
        xPath.stroke()
        
        
        //create the path
        let xPath2 = UIBezierPath()
        xPath2.lineCapStyle = .round
        xPath2.lineWidth = xThickness
        
        xPath2.move(to: CGPoint(
            x:xMargin,
            y:xMargin))
        xPath2.addLine(to: CGPoint(
            x:bounds.width-xMargin,
            y:bounds.height-xMargin))
        
        xPath2.move(to: CGPoint(
            x:bounds.width-xMargin,
            y:xMargin))
        xPath2.addLine(to: CGPoint(
            x:xMargin,
            y:bounds.height-xMargin))
            
        UIColor.white.setStroke()
        xPath2.stroke()
    }

}
