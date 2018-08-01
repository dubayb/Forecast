//
//  Extensions.swift
//  Forecast
//
//  Created by Bryan Dubay on 6/4/18.
//  Copyright © 2018 Bryan Dubay. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func temperatureLabel(low:Double,high:Double) {
        let tempString = "Low: \(String(Int(low.rounded()))  )°\nHigh: \( String(Int(high.rounded())) )°"
        self.text = tempString
    }
}
extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
