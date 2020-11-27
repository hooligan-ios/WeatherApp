//
//  HourlyCollectionViewCell.swift
//  WeatherGifts
//
//  Created by ilya Yudakov on 27.11.2020.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourlyLabel: UILabel!
    @IBOutlet weak var hourlyTemperature: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
//    var hourlyWeather: hourlyWeather! {
//        didSet {
//            hourlyLabel.text = hourlyWeather.hour
//            hourlyTemperature.text = "\(hourlyWeather.hourlyTemperature)°"
//            iconImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
//        }
//    }
    
}
