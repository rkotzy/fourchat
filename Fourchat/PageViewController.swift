//
//  PageViewController.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/5/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import MapKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, CameraViewControllerDelegate, MapViewControllerDelegate, CheckinViewControllerDelegate {

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FoursquareManager.sharedManager().accessToken == nil {
            present(AuthViewController(), animated: true, completion: nil)
        } else {
            let initialViewController = orderedViewControllers[1]
                setViewControllers([initialViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        if let x = orderedViewControllers[previousIndex] as? MapView {
            x.delegate = self
            return x
        } else if let x = orderedViewControllers[previousIndex] as? CameraViewController {
            x.delegate = self
            return x
        } else if let x = orderedViewControllers[previousIndex] as? CheckinView {
            x.delegate = self
            return x
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        if let x = orderedViewControllers[nextIndex] as? MapView {
            x.delegate = self
            return x
        } else if let x = orderedViewControllers[nextIndex] as? CameraViewController {
            x.delegate = self
            return x
        } else if let x = orderedViewControllers[nextIndex] as? CheckinView {
            x.delegate = self
            return x
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        return [self.newViewController(name: "checkinViewController"),
                self.newViewController(name: "cameraViewController"),
                self.newViewController(name: "mapViewController")]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: name)
        
        if let camera = vc as? CameraViewController {
            camera.delegate = self
            return camera
        }
        
        return vc
    }
    
    func goToLastPage() {
        
        if let vc = orderedViewControllers.last {
            setViewControllers([vc], direction: .forward, animated: false, completion: nil)

        }
    }
    
    // MARK: - Quick Checkin delegate
    func quickCheckIn(venueId: String?, location: CLLocation?) {
        
        goToLastPage()

        
        // need a venueId
        guard let venueId = venueId else {
            return
        }
        
        // need a ll
        guard let location = location else {
            return
        }
        
        // checkin
        FoursquareManager.sharedManager().checkinWithVenueId(venueId, location: location, shout: nil, completion: {
            (response : JSON, error : NSError?) in
            if error != nil {
                print(error?.description)
            }
            
        })
    }
    
    // MARK: - Map View Controller Delegate
    func backToCamera() {
        self.goToPreviousPage()
    }
    
    // MARK: - CameraViewControllerDelegate
    func showMap() {
        goToNextPage()
    }
    
    func quickCheckin() {
        goToPreviousPage()
    }
    
    func checkedIn(venueId: String, location: CLLocation, photo: UIImage, text: String?) {
        
        
        // Go to the map view
        goToNextPage()

        
        // checkin
        FoursquareManager.sharedManager().checkinWithVenueId(venueId, location: location, shout: text, completion: {
            (response : JSON, error : NSError?) in
            if error == nil {                
                
                // add the photo to the checkin
                FoursquareManager.sharedManager().addPhotoToCheckin(
                    response["response"]["checkin"]["id"].stringValue,
                    photo: photo,
                    postText: text,
                    completion: {
                        (error) in
                        
                        if error == nil {
                            print("photo added to checkin")
                        } else {
                            print(error?.description)
                        }
                        
                }) // photo added
                
            } else {
                print(error?.description)
            }
            
        }) // checkin added
        
        
        // add tip to Foursquare
        if let tip = text {
            FoursquareManager.sharedManager().addTipToVenueId(venueId, tip: tip, completion: {
                (response : JSON, error : NSError?) in
                
                
                if error == nil {
                    print("tip added")
                    // add the photo to the checkin
                    FoursquareManager.sharedManager().addPhotoToTip(
                        response["response"]["tip"]["id"].stringValue,
                        photo: photo,
                        postText: text,
                        completion: {
                            (error) in
                            
                            if error == nil {
                                print("photo added to tip")
                            } else {
                                print(error?.description)
                            }
                            
                    }) // photo added
                } else {
                    print(error?.description)
                }
            }) // tip added
        }
    }
}


extension UIPageViewController {
    
    func goToNextPage(){
        
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        
    }
    
    
    func goToPreviousPage(){
        
        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
        
    }
    
}
