//
//  CheckinView.swift
//  Fourchat
//
//  Created by Ryan Kotzebue on 10/24/16.
//  Copyright © 2016 Ryan Kotzebue. All rights reserved.
//

import UIKit
import CoreLocation

protocol CheckinViewControllerDelegate {
    func quickCheckIn(venueId: String?, location: CLLocation?)
}

class CheckinView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate : CheckinViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Quick Checkin"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(newVenuesLoaded), name: kVenuesLoadedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // check if snap-to-place has loaded yet
        if FoursquareManager.sharedManager().newVenuesLoaded == false {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
        

    }
    
    func newVenuesLoaded() {
        
        tableView.reloadData()
        
        if tableView.isHidden {
            tableView.isHidden = false
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FoursquareManager.sharedManager().venues.count-1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 140
        }
        return 90
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckinCell

        cell.setupCell(venue: FoursquareManager.sharedManager().venues[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(title: "Great Checkin! 📸📍🐝🎉", message: nil, dismissTitle: "Thanks!")
        delegate?.quickCheckIn(venueId: FoursquareManager.sharedManager().venues[indexPath.row].venueId, location: userLocation)
    }

}
