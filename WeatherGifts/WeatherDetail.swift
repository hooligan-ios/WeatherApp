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

private let hourformatter: DateFormatter = {
    let  hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "ha"
    return hourFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather {
    var hourly: String
    var hourlyTemperature: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation{
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct Current:Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    struct Weather: Codable {
        var id: Int
        var description: String
        var icon: String
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
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
    var hourlyWeatherData: [HourlyWeather] = []
    
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
                
                let lastHour = min(24, result.hourly.count)
                if lastHour  > 0 {
                    for index in 1...lastHour {
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        hourformatter.timeZone = TimeZone(identifier: result.timezone)
                        let hour = hourformatter.string(from: hourlyDate)
//                        let hourlyIcon = self.fileNameForIcon(icon: result.hourly[index].weather[0].icon)
                        let hourlyIcon = self.systemNameFromId(id: result.hourly[index].weather[0].id, icon: result.hourly[index].weather[0].icon)
                        let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                        let hourlyWeather = HourlyWeather(hourly: hour, hourlyTemperature: hourlyTemperature, hourlyIcon: hourlyIcon)
                        self.hourlyWeatherData.append(hourlyWeather)
                    }
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
    
    private func systemNameFromId(id: Int, icon: String) -> String {
        switch  id {
        case 200...299: return "cloud.bolt.rain"
        case 300...399: return "cloud.drizzle"
        case 500, 501, 520, 521, 531: return "cloud.rain"
        case 511, 611...616: return "sleet"
        case 600...602, 620...622: return "snow"
        case 701, 711, 741: return "cloud.fog"
        case 721:
            return (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
        case 731, 751, 761, 762:
            return (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
        case 771: return "wind"
        case 781: return "tornado"
        case 800: return (icon.hasSuffix("d") ? "sun.max" : "moon")
        case 801, 802:
            return (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
        case 803, 804: return "cloud"
        default:
            return "questionmark.diamond"
        }
    }
}
