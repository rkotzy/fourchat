//
//  Venue.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

struct Venue: CustomStringConvertible {

    let venueId: String?
    let name: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let categoryEmoji: String!
    
    var description: String {
        return "<venueId=\(venueId)"
            + ", name=\(name)"
            + ", address=\(address)"
            + ", latitude=\(latitude), longitude=\(longitude)"
            + ", categoryEmoji=\(categoryEmoji)>"
    }

    init(json: JSON) {

        self.venueId = json["id"].string
        self.name = json["name"].string
        self.address = json["location"]["address"].string
        self.latitude = json["location"]["lat"].double
        self.longitude = json["location"]["lng"].double

        // Primary Category
        if json["categories"].arrayValue.count > 0 {
            
            if let category = categories[json["categories"][0]["id"].stringValue] {
                self.categoryEmoji = category
            } else {
                self.categoryEmoji = "📍"
            }
        }
        else {
            self.categoryEmoji = nil
        }
    }
}
