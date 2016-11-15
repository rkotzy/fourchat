//
//  CameraPreviewView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import MapKit

protocol CameraPreviewViewDelegate {
    func checkIn(venueId: String, location: CLLocation, photo: UIImage, text: String?)
}


class CameraPreviewView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    var delegate : CameraPreviewViewDelegate?
    var snappedLocation : CLLocation?
    var imageView : UIImageView!
    var collectionView : UICollectionView!
    var currentVenue : Venue?
    var sendButton : UIButton!
    var tipRatingView : TipRatingView!
    var activityView : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            currentVenue = FoursquareManager.sharedManager().venues[self.currentPage]
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // setup tip rating view
        tipRatingView = TipRatingView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 55))
        
        // add observer for new venues loaded and keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(newVenuesLoaded), name: kVenuesLoadedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden), name:.UIKeyboardWillHide, object: nil)

        
        // collection view setup
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: frame.width, height: frame.height)
        layout.scrollDirection = .horizontal
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 80)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
//        let nibName = UINib(nibName: "CarouselCollectionViewCell", bundle: Bundle.main)
//        collectionView.register(nibName, forCellWithReuseIdentifier: "CarouselCollectionViewCell")
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: "CarouselCollectionViewCell")
        addSubview(collectionView)
        
        // add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraPreviewView.tappedView))
        addGestureRecognizer(tapGesture)
        
        // add close button
        let closeButton = ClosePreviewButton(frame: CGRect(x: 12, y: 16, width: 34, height: 34))
        closeButton.addTarget(self, action: #selector(CameraPreviewView.close), for: .touchUpInside)
        addSubview(closeButton)
        
        // add send button
        sendButton = UIButton(frame: CGRect(x: frame.width - 62, y: frame.height - 66, width: 50, height: 50))
        sendButton.layer.cornerRadius = 50.0/2.0
        sendButton.backgroundColor = UIColor(colorLiteralRed: 0.05, green: 0.61, blue: 0.95, alpha: 1)
        sendButton.titleLabel?.font = UIFont.fontAwesomeOfSize(30)
        sendButton.setTitle(String.fontAwesomeIconWithName(.Check), for: .normal)
        sendButton.addTarget(self, action: #selector(CameraPreviewView.checkIn), for: .touchUpInside)
        addSubview(sendButton)
        
        // check if snap-to-place has loaded yet
        if FoursquareManager.sharedManager().newVenuesLoaded == false {
            sendButton.isHidden = true
            activityView.center = center
            addSubview(activityView)
        } else {
            currentVenue = FoursquareManager.sharedManager().venues[self.currentPage]
        }
        
        isUserInteractionEnabled = true

    }
    
    func keyboardWasShown(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tipRatingView.frame.origin.y = frame.height - keyboardSize.height - tipRatingView.frame.height
        }
        
        tipRatingView.promptLabel.isHidden = false
        tipRatingView.textField.textAlignment = .left
    }
    
    func keyboardWasHidden () {
        if (tipRatingView.textField.text == nil || tipRatingView.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0) {
            tipRatingView.removeFromSuperview()
        } else {
            tipRatingView.textField.textAlignment = .center
            tipRatingView.promptLabel.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(image: UIImage) {
        // add imageView
        imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        insertSubview(imageView, at: 0)
    }
    
    func newVenuesLoaded() {
        if sendButton.isHidden {
            sendButton.isHidden = false
        }
        
        if subviews.contains(activityView) {
            activityView.removeFromSuperview()
        }
        currentVenue = FoursquareManager.sharedManager().venues[self.currentPage]
        collectionView.reloadData()
    }
    
    func tappedView() {
        if subviews.contains(tipRatingView) {
            if tipRatingView.textField.isFirstResponder {
                if (tipRatingView.textField.text == nil || tipRatingView.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).characters.count == 0) {
                tipRatingView.removeFromSuperview()
                } else {
                    tipRatingView.textField.resignFirstResponder()
                }
            } else {
                tipRatingView.textField.becomeFirstResponder()
            }
        } else {
            addSubview(tipRatingView)
            tipRatingView.textField.becomeFirstResponder()
        }
    }
    
    func close() {
        removeFromSuperview()
    }
    
    func checkIn() {
        
        // need an image
        guard let image = imageView.image else {
            return
        }
        
        // need a venueId
        guard let venueId = currentVenue?.venueId else {
            return
        }
        
        // need a ll
        let latlng = snappedLocation ?? userLocation
        
        if latlng == nil {
            return
        }
        
        delegate?.checkIn(venueId: venueId, location: latlng!, photo: image, text: tipRatingView.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines))
        close()
    }
    
    // MARK: - Card Collection Delegate & DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FoursquareManager.sharedManager().venues.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCollectionViewCell", for: indexPath) as! CarouselCollectionViewCell
        cell.setupView(withVenue: FoursquareManager.sharedManager().venues[(indexPath as NSIndexPath).row])
        return cell
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }

}
