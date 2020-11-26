//
//  WeatherDetail.swift
//  WeatherGifts
//
//  Created by ilya Yudakov on 25.11.2020.
//

import Foundation

private let dateformatter: DateFormatter = {
    let  dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

class WeatherDetail: WeatherLocation{
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
    }
    
    private struct Current:Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0.0
    var summary = ""
    var dailyIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    
    func getData(complition: @escaping () -> ()) {
        
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(APIKeys.apiKey)"
        
        guard  let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            complition()
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { [self] data, response, error in
            if let error = error {
                print("😡 ERROR: \(error.localizedDescription)")
            }
            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = result.current.temp.rounded()
                self.summary = result.current.weather[0].description
                self.dailyIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
                for index in 0..<result.daily.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateformatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekDay = dateformatter.string(from: weekdayDate)
                    let dailyIcon = fileNameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekDay, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                }
            } catch {
                print("😡 JSON ERROR: \(error.localizedDescription)")
            }
            complition()
        }
        task.resume()
    }
    
    private func fileNameForIcon(icon: String) -> String {
        var newFileName = ""
        switch icon {
        case "01d":
            newFileName = "01d@2x.png"
        case "01n":
            newFileName = "01n@2x.png"
        case "02d":
            newFileName = "02d@2x.png"
        case "02n":
            newFileName = "02n@2x.png"
        case "03d", "03n":
            newFileName = "03d@2x.png"
        case "04d", "04n":
            newFileName = "03d@2x.png"
        case "09d", "09n":
            newFileName = "09d@2x.png"
        case "10d", "10n":
            newFileName = "09d@2x.png"
        case "11d", "11n":
            newFileName = "11d@2x.png"
        case "13d", "13n":
            newFileName = "13d@2x.png"
        case "50d", "50n":
            newFileName = "50d@2x.png"

        default:
            newFileName = " "
        }
        return newFileName
    }
}
