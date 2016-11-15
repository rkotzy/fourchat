//
//  CameraCaptureView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

protocol CameraCaptureViewDelegate {
    func focus(atPoint: CGPoint)
    func flipCamera()
    func takePicture()
    func quickCheckin()
    func showMap()
}

class CameraCaptureView: UIView {

    var delegate : CameraCaptureViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // add snap button
        let picButton = SnapButton(frame: CGRect(x: frame.width/2-40, y: frame.height-80-20, width: 80, height: 80))
        picButton.addTarget(self, action: #selector(CameraCaptureView.takePicture), for: .touchDown)
        addSubview(picButton)
        
        // add quick checkin button
        let checkinButton = UIButton(frame: CGRect(x: 12, y: frame.height-70-20, width: 70, height: 70))
        checkinButton.titleLabel?.textColor = UIColor.white
        checkinButton.titleLabel?.font = UIFont.fontAwesomeOfSize(40)
        checkinButton.setTitle(String.fontAwesomeIconWithName(.MapMarker), for: .normal)
        checkinButton.addTarget(self, action: #selector(CameraCaptureView.quickCheckin), for: .touchDown)
        addSubview(checkinButton)
        
        
        // add map button
        let mapButton = UIButton(frame: CGRect(x: frame.width-70-12, y: frame.height-70-20, width: 70, height: 70))
        mapButton.titleLabel?.textColor = UIColor.white
        mapButton.titleLabel?.font = UIFont.fontAwesomeOfSize(35)
        mapButton.setTitle(String.fontAwesomeIconWithName(.MapO), for: .normal)
        mapButton.addTarget(self, action: #selector(CameraCaptureView.showMap), for: .touchDown)
        addSubview(mapButton)
        
        // add flip gesture recognizer
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(CameraCaptureView.flipCamera))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first {
            delegate.focus(atPoint: touch.location(in: self))
        }
    }
    
    func takePicture() {
        delegate.takePicture()
    }
    
    func flipCamera() {
        delegate.flipCamera()  
    }
    
    func quickCheckin() {
        delegate.quickCheckin()
    }
    
    func showMap() {
        delegate.showMap()
    }

}
