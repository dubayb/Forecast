//
//  AppDelegate.swift
//  Forecast
//
//  Created by Bryan Dubay on 5/31/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let locationService = LocationService.sharedInstance
        locationService.configureLocationManager(delegate: self)
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        LocationService.usersLocation = location
        let nav = self.window?.rootViewController as! UINavigationController
        let forecastVC = nav.topViewController as! ForecastCollectionViewController
        let geocoder = CLGeocoder()
        LocationService.sharedInstance.locationManager.stopUpdatingLocation()
        LocationService.sharedInstance.locationManager.delegate = nil
        geocoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) in
            if let title = placemarks?[0].locality {
                forecastVC.title = title
            }
            forecastVC.location = location
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let cds = CoreDataStack.sharedInstance
        cds.saveContext()
    }



   
}

