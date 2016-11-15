//
//  CameraViewController.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreLocation
import MapKit

protocol CameraViewControllerDelegate {
    func checkedIn(venueId: String, location: CLLocation, photo: UIImage, text: String?)
    func showMap()
    func quickCheckin()
}

class CameraViewController: UIViewController, CameraCaptureViewDelegate, CameraPreviewViewDelegate {
    
    var delegate : CameraViewControllerDelegate?
    let cameraEngine = CameraEngine()
    var captureView : CameraCaptureView!
    
    var r : Request!
    var isLocationInitialized = false
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layer = self.cameraEngine.previewLayer else {
            return
        }
        layer.frame = self.view.bounds
        layer.masksToBounds = true
        self.view.layer.insertSublayer(layer, at: 0)
        
        // add capture layer
        captureView = CameraCaptureView(frame: view.bounds)
        captureView.delegate = self
        view.addSubview(captureView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("token: \(FoursquareManager.sharedManager().accessToken)")
        
        if FoursquareManager.sharedManager().accessToken == nil {
            present(AuthViewController(), animated: true, completion: nil)
        } else {
            
            // set up camera engine
            cameraEngine.sessionPresset = .photo
            cameraEngine.cameraFocus = .autoFocus
            cameraEngine.flashMode = .auto
            cameraEngine.startSession()
            
            //start location
            r = Location.getLocation(withAccuracy: .block, frequency: .continuous, timeout: 30, onSuccess: { (location) in
                
                //Guard
                if FoursquareManager.sharedManager().accessToken == nil {
                    return
                }
                
                if self.isLocationInitialized == true && userLocation?.timestamp != nil && userLocation!.timestamp.timeIntervalSinceNow < TimeInterval(-30) {
                    self.isLocationInitialized = false
                }
                
                if self.isLocationInitialized == false {
                    userLocation = location
                    self.snapToPlace(coordinate: location.coordinate)
                    self.isLocationInitialized = true
                }
                
            }) { (lastValidLocation, error) in
                self.showAlert(title: "Error getting location", message: error.localizedDescription, dismissTitle: "OK")
            }
            
            r.onAuthorizationDidChange = { newStatus in
                if newStatus == CLAuthorizationStatus.denied {
                    self.showAlert(title: "You denied location services", message: "Go to settings and enable location access when you're using the app.", dismissTitle: "Ok")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        r.cancel()
    }
    
    func snapToPlace(coordinate: CLLocationCoordinate2D) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        FoursquareManager.sharedManager().searchVenuesWithCoordinate(coordinate, completion: {
            (error) in
            
            if error != nil {
                self.showAlert(title: "Error:", message: error?.localizedDescription, dismissTitle: "OK")
            } else {
                FoursquareManager.sharedManager().newVenuesLoaded = true
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    // MARK: - CameraCaptureView Delegate
    func focus(atPoint: CGPoint) {
        cameraEngine.focus(atPoint)
    }
    
    func flipCamera() {
        cameraEngine.switchCurrentDevice()
    }
    
    func showMap() {
        delegate?.showMap()
    }
    
    func quickCheckin() {
        delegate?.quickCheckin()
    }
    
    func takePicture() {
        
        // stop getting location
        r.cancel()
        
        // add picture layer
        cameraEngine.capturePhoto { (image , error) -> (Void) in
            DispatchQueue.main.async(execute: { () -> Void in
                    if let i = image {
                        let previewView = CameraPreviewView(frame: self.view.bounds)
                        previewView.delegate = self
                        previewView.snappedLocation = userLocation
                        previewView.add(image: i)
                        self.view.addSubview(previewView)
                    }
                })
        }
    }
    
    // MARK: - CameraPreviewView Delegate
    func checkIn(venueId: String, location: CLLocation, photo: UIImage, text: String?) {
        showAlert(title: "Great Checkin! 📸📍🐝🎉", message: nil, dismissTitle: "Thanks!")
        
        delegate?.checkedIn(venueId: venueId, location: location, photo: photo, text: text)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String?, dismissTitle: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: dismissTitle, style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
}

