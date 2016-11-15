//
//  EmojiPin.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/17/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import Foundation
import MapKit

class EmojiPin: NSObject, MKAnnotation {
    let title: String?
    let name: String?
    let shout: String?
    let createdAt: Date?
    let venue: Venue?
    let id: String
    let coordinate: CLLocationCoordinate2D
    let photoURL: URL?
    
    init(checkin: Checkin) {
        self.id = checkin.checkinId
        self.title = checkin.venue?.name
        self.shout = checkin.shout
        self.photoURL = checkin.photoURL
        
        if let f = checkin.firstName, let l = checkin.lastName?.characters.first {
            self.name = f + " " + String(l) + "."
        } else {
            self.name = checkin.firstName
        }
        
        self.createdAt = checkin.createdAt
        self.venue = checkin.venue
        self.coordinate = CLLocationCoordinate2D(latitude: checkin.venue?.latitude ?? 0.0, longitude: checkin.venue?.longitude ?? 0.0)
                
        super.init()
    }
    
    var subtitle: String? {
        if let d = createdAt, let u = name {
            return "\(u) - \(timeAgoSince(d))"
        }
        return name
    }
}
