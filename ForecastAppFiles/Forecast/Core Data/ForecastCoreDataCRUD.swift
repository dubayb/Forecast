//
//  ForecastCoreDataCRUD.swift
//  Forecast
//
//  Created by Bryan Dubay on 6/3/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftSky
import CoreLocation

class ForecastCoreDataInteractor : NSObject , NSFetchedResultsControllerDelegate {
    let cds = CoreDataStack.sharedInstance
    var midnight : NSDate  {
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        return cal.startOfDay(for: date) as NSDate
    }
    func saveForecast (aLocation:CLLocationCoordinate2D,forecasts:[DataPoint]) {
        let managedObjectContext = cds.persistentContainer.viewContext
        for dataPoint in forecasts {
            let forecast = Forecast(entity: Forecast.entity(), insertInto: managedObjectContext)
            forecast.date = dataPoint.time
            forecast.icon = dataPoint.icon
            forecast.summary = dataPoint.summary
            guard let maxTemp = dataPoint.temperature?.max?.value , let minTemp = dataPoint.temperature?.min?.value else { return }
            forecast.maxTemp = maxTemp
            forecast.minTemp = minTemp
        }
        cds.saveContext()
    }

    lazy var fetchedOldResultsController: NSFetchedResultsController<Forecast> = {
        let fetchRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
        // Configure Fetch Request
        fetchRequest.predicate = NSPredicate(format: "date < %@", midnight)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedOldResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cds.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedOldResultsController
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Forecast> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@", midnight)
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
}
