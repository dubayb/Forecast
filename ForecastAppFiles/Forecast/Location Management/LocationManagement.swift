//
//  LocationManagement.swift
//  Forecast
//
//  Created by Bryan Dubay on 5/31/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import Foundation
import CoreLocation

@objc class LocationService : NSObject  {
    //get lat long and convert it to city and state
    static var usersLocation: CLLocationCoordinate2D!
    
    static let sharedInstance: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    let locationManager = CLLocationManager()
    func configureLocationManager(delegate:CLLocationManagerDelegate){
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = delegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
}

