//
//  ApiClient.swift
//  PlatedChallenge
//
//  Created by Bryan Dubay on 5/22/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import Foundation
import SwiftSky
import CoreData
import CoreLocation

struct ApiClient {
    
    //return fetched results
    static func performForecastRequest(location:CLLocationCoordinate2D , completion: @escaping ( Result <Any>) -> Void ) {
        SwiftSky.secret = NetworkConstants.foreCastApiKey
        SwiftSky.hourAmount = .hundredSixtyEight
        let foreCastCRUD = ForecastCoreDataInteractor()
        SwiftSky.get([.days],
                     at: Location(latitude: location.latitude, longitude: location.longitude)
        ) { result in
            switch result {
            case .success(let forecast):
                if let dataPoints = forecast.days?.points {
                    foreCastCRUD.saveForecast(aLocation: location, forecasts:dataPoints)
                }
                completion(Result.success(forecast.days?.points as Any))
                
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
    
    
}

enum Result <T> {
    case success(T)
    case failure(Error)
}
