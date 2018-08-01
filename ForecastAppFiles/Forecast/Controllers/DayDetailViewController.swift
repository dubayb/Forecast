//
//  DayDetailViewController.swift
//  Forecast
//
//  Created by Bryan Dubay on 6/4/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import UIKit

class DayDetailViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    var forecast: Forecast!
    override func viewDidLoad() {
        bindDetails(detailForecast: forecast)
    }
    func bindDetails(detailForecast : Forecast) {
        dateLabel.text = detailForecast.date?.toString(dateFormat: "MMM dd")
        if let icon = detailForecast.icon {
            iconImageView.image = UIImage.init(named:icon )
        }
        let min = detailForecast.minTemp
        let max = detailForecast.maxTemp
        temperatureLabel.temperatureLabel(low: min, high: max)
        summaryLabel.text = forecast.summary
    }

}
