//
//  TipRatingView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/5/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

class TipRatingView: UIView, UITextFieldDelegate {
    
    var textField : UITextField!
    var promptLabel : UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        promptLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        promptLabel.textColor = UIColor.white
        promptLabel.shadowOffset = CGSize(width: 1, height: 1)
        promptLabel.shadowColor = UIColor.darkGray
        promptLabel.textAlignment = .center
        promptLabel.text = "Leave a tip: What's good here?"
        addSubview(promptLabel)
        
        textField = UITextField(frame: CGRect(x: 0, y: frame.height - 35, width: frame.width, height: 35))
        textField.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        textField.textColor = UIColor.white
        textField.returnKeyType = .done
        textField.delegate = self
        addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
