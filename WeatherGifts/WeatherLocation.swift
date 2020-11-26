//
//  WeatherLocation.swift
//  WeatherGifts
//
//  Created by ilya Yudakov on 23.11.2020.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
