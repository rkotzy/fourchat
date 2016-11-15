//
//  Global.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import Foundation
import UIKit
import MapKit

var userLocation: CLLocation?

let clientId = "(YOUR_CLIENT_ID)"
let callback = "(YOUR_CALLBACK_URL)"

let kVenuesLoadedNotification = NSNotification.Name(rawValue: "kVenuesLoadedNotification")

let kProfilePhotoSize : CGFloat = 60

let kMainColor = UIColor(colorLiteralRed: 233/255.0, green: 69/255.0, blue: 117/255.0, alpha: 1.0)
