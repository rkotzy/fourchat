//
//  Checkin.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/17/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import Foundation

let kPhotoMaxCap = "cap500"

struct Checkin: CustomStringConvertible {
    
    let checkinId: String
    let venue: Venue?
    let createdAt: Date?
    let firstName: String?
    let lastName: String?
    let shout: String?
    let userPhotoURL: URL?
    let photoURL: URL?
    
    var description: String {
        return "<checkinId=\(checkinId)"
            + ", venue=\(venue)"
            + ", createdAt=\(createdAt)"
            + ", firstName=\(firstName)"
            + ", lastName=\(lastName)"
            + ", shout=\(shout)"
            + ", userPhotoURLString=\(userPhotoURL)"
            + ", photoURLString=\(photoURL)>"
    }
    
    init(json: JSON) {
        
        self.checkinId = json["id"].stringValue
        self.venue = Venue(json: json["venue"])
        self.createdAt = Date(timeIntervalSince1970: json["createdAt"].doubleValue)
        self.firstName = json["user"]["firstName"].string
        self.lastName = json["user"]["lastName"].string
        self.shout = json["shout"].string

        
        // User Photo
        let userPhotoPrefix = json["user"]["photo"]["prefix"].stringValue
        let userPhotoSuffix = json["user"]["photo"]["suffix"].stringValue
        let userPhotoString = userPhotoPrefix + "300x300" + userPhotoSuffix
        self.userPhotoURL = URL(string: userPhotoString as String)
        
        // Photo
        if json["photos"]["items"].arrayValue.count > 0 {
            let prefix = json["photos"]["items"][0]["prefix"].stringValue
            let suffix = json["photos"]["items"][0]["suffix"].stringValue
            let photoString = prefix + kPhotoMaxCap + suffix
            self.photoURL = URL(string: photoString as String)
        }
        else {
            photoURL = nil
        }

    }
}
