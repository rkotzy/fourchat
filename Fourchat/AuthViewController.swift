//
//  AuthViewController.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/4/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, FoursquareAuthClientDelegate {

    @IBAction func tappedConnectButton(_ sender: AnyObject) {
        
        // Open auth view
        let client = FoursquareAuthClient(clientId: clientId, callback: callback, delegate: self)
        client.authorizeWithRootViewController(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FoursquareManager.sharedManager().accessToken != nil {
            dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - FoursquareAuthClientDelegate
    
    func foursquareAuthClientDidSucceed(_ accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        FoursquareManager.sharedManager().accessToken = accessToken
    }
    
    func foursquareAuthClientDidFail(_ error: NSError) {
        print(error.description)
    }


}
