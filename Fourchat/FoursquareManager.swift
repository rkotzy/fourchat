//
//  FoursquareManager.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class FoursquareManager: NSObject {

    var accessToken: String!
    var newVenuesLoaded : Bool = false
    var venues = [Venue]()
    var checkins = [Checkin]()
    var checkinsRefreshed : NSDate?

    class func sharedManager() -> FoursquareManager {

        struct Static {
            static let instance = FoursquareManager()
        }
        return Static.instance
    }

    func searchVenuesWithCoordinate(_ coordinate: CLLocationCoordinate2D, completion: ((NSError?) -> ())?) {

        let client = FoursquareAPIClient(accessToken: accessToken)
        
        let parameter: [String: String] = [
            "ll": "\(coordinate.latitude),\(coordinate.longitude)",
            "limit" : "25"
        ];

        client.requestWithPath("venues/search", parameter: parameter) {
            [weak self] (data, error) in

            let json = JSON(data: data!)
            self?.venues = (self?.parseVenues(json["response"]["venues"]))!
            print("venues loaded")
            self?.newVenuesLoaded = true
            NotificationCenter.default.post(name: kVenuesLoadedNotification, object: nil)
            completion?(error)
        }
    }
    
    func getRecentCheckins( completion: ((NSError?) -> ())?) {
        
        let client = FoursquareAPIClient(accessToken: accessToken)
        
        let parameter: [String: String] = [
            "limit" : "100"
        ];
        
        client.requestWithPath("checkins/recent", parameter: parameter) {
            [weak self] (data, error) in
            
            let json = JSON(data: data!)
            self?.checkins = (self?.parseCheckins(json["response"]["recent"]))!
            print("checkins loaded")
            self?.checkinsRefreshed = NSDate()
            completion?(error)
        }
    }
    

    func checkinWithVenueId(_ venueId: String, location: CLLocation, shout: String?, completion: ((JSON, NSError?) -> ())?) {

        let client = FoursquareAPIClient(accessToken: accessToken)

        let parameter: [String: String] = [
            "venueId": venueId,
            "shout": shout ?? "",
            "ll": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "llAcc": "\(location.horizontalAccuracy)",
            "alt": "\(location.altitude)",
            "altAcc" : "\(location.verticalAccuracy)"
        ];

        client.requestWithPath("checkins/add", method: .POST, parameter: parameter) {
            (data, error) in

            let json = JSON(data: data!)
            completion?(json, error)
        }
    }
    
    func addPhotoToCheckin(_ checkinId: String, photo: UIImage, postText: String?, completion: ((NSError?) -> ())?) {
        
        guard let imageData = UIImageJPEGRepresentation(photo, 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        
        let parameter: [String: String] = [
            "oauth_token" : accessToken,
            "checkinId": checkinId,
            "public" : "1",
            "postText": postText ?? "",
            "v": "20161004"
        ];
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                
                for (key, value) in parameter {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
            to: "https://api.foursquare.com/v2/photos/add",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        print(response)

                        switch response.result {
                        case .success:
                            completion?(nil)
                        case .failure(let error):
                            completion?(error as NSError?)
                        }

                    }
                case .failure(let encodingError):
                    print(encodingError)
                    completion?(NSError(domain: "Image encoding error", code: 420, userInfo: nil))
                }
            }
        )
    }
    
    func addPhotoToTip(_ tipId: String, photo: UIImage, postText: String?, completion: ((NSError?) -> ())?) {
        
        guard let imageData = UIImageJPEGRepresentation(photo, 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
        }
        
        let parameter: [String: String] = [
            "oauth_token" : accessToken,
            "tipId": tipId,
            "public" : "1",
            "postText": postText ?? "",
            "v": "20161004"
        ];
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                
                for (key, value) in parameter {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            },
            to: "https://api.foursquare.com/v2/photos/add",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        print(response)
                        
                        switch response.result {
                        case .success:
                            completion?(nil)
                        case .failure(let error):
                            completion?(error as NSError?)
                        }
                        
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    completion?(NSError(domain: "Image encoding error", code: 420, userInfo: nil))
                }
            }
        )
    }
    
    func addTipToVenueId(_ venueId: String, tip: String, completion: ((JSON, NSError?) -> ())?) {
        
        let client = FoursquareAPIClient(accessToken: accessToken)
        
        let parameter: [String: String] = [
            "venueId": venueId,
            "text": tip
        ];
        
        client.requestWithPath("tips/add", method: .POST, parameter: parameter) {
            (data, error) in
            
            let json = JSON(data: data!)
            completion?(json, error)
        }
    }

    func parseVenues(_ venuesJSON: JSON) -> [Venue] {

        var venues = [Venue]()

        for (key: _, venueJSON: JSON) in venuesJSON {
            venues.append(Venue(json: JSON))
        }

        return venues
    }
    
    func parseCheckins(_ checkinsJSON: JSON) -> [Checkin] {
        
        var checkins = [Checkin]()
        
        for (key: _, checkinJSON: JSON) in checkinsJSON {
            checkins.append(Checkin(json: JSON))
        }
        
        return checkins
    }
    
}
