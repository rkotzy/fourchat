//
//  MapView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/17/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func backToCamera()
}

class MapView: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var delegate : MapViewControllerDelegate!
    var userLocationSet = false
    let kMapLatOffset : Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup MapView
        mapView.delegate = self
        mapView.showsPointsOfInterest = false
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        
        // setup collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let refreshTime = FoursquareManager.sharedManager().checkinsRefreshed
        
        print(refreshTime?.timeIntervalSinceNow)
        
        if refreshTime == nil || refreshTime!.timeIntervalSinceNow <= TimeInterval(-300) {
            getCheckins()
        }
    }
    
    func getCheckins() {
        FoursquareManager.sharedManager().getRecentCheckins(completion: {
            (error) in
            
            if error != nil {
                self.showAlert(title: "Error:", message: error?.localizedDescription, dismissTitle: "OK")
            } else {
                for c in FoursquareManager.sharedManager().checkins {
                    self.mapView.addAnnotation(EmojiPin(checkin: c))
                }
                self.collectionView.reloadData()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    // MARK: - Helpers
    
    func centerMapOnLocation(location: CLLocation) {
        
        var lat : Double!
        if location.coordinate.latitude < 0 {
            lat = location.coordinate.latitude - kMapLatOffset
        } else {
            lat = location.coordinate.latitude + kMapLatOffset
        }
                
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: lat, longitude: location.coordinate.longitude), 4000, 4000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let checkinItem = FoursquareManager.sharedManager().checkins[indexPath.row]
        
        guard let lat = checkinItem.venue?.latitude else {
            return
        }
        guard let lng = checkinItem.venue?.longitude else {
            return
        }
        
        let location = CLLocation(latitude: lat, longitude: lng)
        
        // deselect annotation
        for a in mapView.selectedAnnotations {
            mapView.deselectAnnotation(a, animated: true)
        }
        
        // find user annotation
        for a in mapView.annotations {
            if let e = a as? EmojiPin {
                if e.id == checkinItem.checkinId {
                    mapView.selectAnnotation(e, animated: true)
                    centerMapOnLocation(location: location)
                    break
                }
            }
        }
    }
    
    
    // MARK: - CollectionView Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FoursquareManager.sharedManager().checkins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FriendCollectionViewCell
        
        // Configure the cell
        cell.setCell(checkin: FoursquareManager.sharedManager().checkins[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionView Delegate Flow Method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: kProfilePhotoSize, height: kProfilePhotoSize + 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    
    
    // MARK: - MapView Delegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        guard let location = userLocation.location else {
            print("invalid location coordinate")
            return
        }
        
        if !userLocationSet && location.horizontalAccuracy < 100 {
            self.userLocationSet = true
            self.centerMapOnLocation(location: location)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? EmojiPin {
            let identifier = "checkin"
            var view: EmojiAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? EmojiAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = EmojiAnnotationView(emojiAnnotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = false
//                view.calloutOffset = CGPoint(x: 0, y: -10)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            view.label.text = annotation.venue?.categoryEmoji
            
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let view = view as? EmojiAnnotationView else {
            return
        }
        
        view.label.font = UIFont.systemFont(ofSize: 33)
        
        let checkinAnnotation = view.annotation as! EmojiPin
        let views = Bundle.main.loadNibNamed("EmojiPinCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! EmojiPinCalloutView
        calloutView.setWith(annotation: checkinAnnotation)
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.5-15)
        view.addSubview(calloutView)
        
        var lat : Double!
        if (view.annotation?.coordinate.latitude)! < 0 {
            lat = (view.annotation?.coordinate.latitude)! - kMapLatOffset
        } else {
            lat = (view.annotation?.coordinate.latitude)! + kMapLatOffset
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: (view.annotation?.coordinate.longitude)!)
        
        mapView.setCenter(coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        guard let view = view as? EmojiAnnotationView else {
            return
        }
        
        view.label.font = UIFont.systemFont(ofSize: 22)
        
        for subview in view.subviews{
            if let s = subview as? EmojiPinCalloutView {
                s.removeFromSuperview()
                break
            }
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        delegate.backToCamera()
    }
}
