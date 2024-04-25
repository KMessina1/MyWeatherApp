/*--------------------------------------------------------------------------------------------------------------------------
    File: Weather_VM.swift
  Author: Kevin Messina
 Created: 4/21/24
Modified:
 
©2024 Creative App Solutions, LLC. - All Rights Reserved.
----------------------------------------------------------------------------------------------------------------------------
NOTES:
--------------------------------------------------------------------------------------------------------------------------*/

import WeatherKit
import CoreLocation
import SwiftUI

let cities = [
    city.init(id: 0, name: "Park, CA", lat: 37.334606, lon: -122.009102),
    city.init(id: 1, name: "Jacksonville, FL", lat: 30.332184, lon: -81.655647),
    city.init(id: 2, name: "Albany, NY", lat: 42.652580, lon: -73.756233),
    city.init(id: 3, name: "Houston, TX", lat: 29.760799, lon: -95.369507),
    city.init(id: 4, name: "Anchorage, AK", lat: 61.216579, lon: -149.899597),
    city.init(id: 5, name: "Current Loc {N/A}", lat: 37.334606, lon: -122.009102),
    city.init(id: 6, name: "Custom Location", lat: 0, lon: 0)
]

struct city {
    let id:Int
    let name:String
    let lat:Double
    let lon:Double
}

@MainActor class WeatherVM: ObservableObject {
    let weatherService = WeatherService()

    @Published var currentTemperature:String = ""
    @Published var feelsLike:String = ""
    @Published var currentHighTemp:String = ""
    @Published var currentLowTemp:String = ""
    @Published var dailyHighLowAbbrev:String = "H: 0°  /  L: 0°"
    @Published var dailyHighLowFull:String = "High: 0°  /  Low: 0°"
    @Published var currentCondition:String = ""
    @Published var currentHumidity:String = ""
    @Published var currentWindSpeed:String = ""
    @Published var currentWindDirection:String = ""
    @Published var currentWindDirImg:String = ""
    @Published var currentWindGust:String = ""
    @Published var asOf:Date = Date()
    @Published var currentPressure:String = ""
    @Published var currentPressureTrend:String = ""
    @Published var currentPressureState:String = ""
    @Published var currentPressureColor:Color = .white
    @Published var currentDewPoint:String = ""

    @Published var hourlyForecast:[HourWeather] = []
    @Published var tenDayForecast:[DayWeather] = []

    @Published var isLoading: Bool = false
    
    @Published var tempUnits: UnitTemperature = .fahrenheit
    @Published var pressUnits: UnitPressure = .inchesOfMercury
    @Published var latitude: Double = 37.334606
    @Published var longitude: Double = -122.009102
    @Published var currentLocation: CLLocation = CLLocation()

    init() {
        self.currentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        fetchCurrentWeather(lat: self.latitude, lon: self.longitude)
    }
    
    func getCurrentLocation() {
        
    }
    
    func fetchCurrentWeather(lat: Double, lon: Double) {
        print("Fetching Weather...")
        
        Task {
            do {
                print("\n----------------------------------------------------")
                print("Current Lat: \( self.latitude), Input Lat: \( lat )")
                print("Current Lon: \( self.longitude), Input Lon: \( lon )")
                print("----------------------------------------------------\n")

                let weather = try await weatherService.weather(for: CLLocation(latitude: lat, longitude: lon))
                DispatchQueue.main.async {
                    self.isLoading = true
                    
                    let temp = weather.currentWeather.temperature.converted(to: self.tempUnits).value.formatted(.number.precision(.fractionLength(0)))
                    let feelsLike = weather.currentWeather.apparentTemperature.converted(to: self.tempUnits).value.formatted(.number.precision(.fractionLength(0)))
                    let hi = weather.dailyForecast.forecast[0].highTemperature.converted(to: self.tempUnits).value.formatted(.number.precision(.fractionLength(0)))
                    let lo = weather.dailyForecast.forecast[0].lowTemperature.converted(to: self.tempUnits).value.formatted(.number.precision(.fractionLength(0)))
                    let humidity = (weather.currentWeather.humidity * 100).formatted(.number.precision(.fractionLength(0)))
                    let windDir = weather.currentWeather.wind.direction.value.formatted(.number.precision(.fractionLength(0)))
                    let windFrom = weather.currentWeather.wind.compassDirection.abbreviation
                    let directionSpeed = weather.currentWeather.wind.speed.converted(to: .milesPerHour).value
                    let windSpeed = directionSpeed.formatted(.number.precision(.fractionLength(1)))
                    switch windFrom {
                        case "N": self.currentWindDirImg = "arrow.up.circle"
                        case "NE","NNE": self.currentWindDirImg = "arrow.up.right.circle"
                        case "E": self.currentWindDirImg = "arrow.right.circle"
                        case "SE","SSE": self.currentWindDirImg = "arrow.down.right.circle"
                        case "S": self.currentWindDirImg = "arrow.down.circle"
                        case "SW","SSW": self.currentWindDirImg = "arrow.down.left.circle"
                        case "W": self.currentWindDirImg = "arrow.left.circle"
                        case "NW","NNW": self.currentWindDirImg = "arrow.up.left.circle"
                        default: self.currentWindDirImg = ""
                    }
                    let directionUnit = weather.currentWeather.wind.direction.unit.symbol
                    let pressureNum = weather.currentWeather.pressure.converted(to: .inchesOfMercury).value
                    let pressure = pressureNum.formatted(.number.precision(.fractionLength(2)))
                    if pressureNum >= 30.20 {
                        self.currentPressureState = "H"
                        self.currentPressureColor = .red
                    } else if pressureNum <= 29.80 {
                        self.currentPressureState = "L"
                        self.currentPressureColor = .blue
                    } else {
                        self.currentPressureState = ""
                        self.currentPressureColor = .white
                    }
                    let pressureTrend = weather.currentWeather.pressureTrend.description.lowercased()
                    if pressureTrend == "rising" {
                        self.currentPressureTrend = "arrow.up"
                    } else if pressureTrend == "falling" {
                        self.currentPressureTrend = "arrow.down"
                    } else if pressureTrend == "steady" {
                        self.currentPressureTrend = "equal"
                    } else {
                        self.currentPressureTrend = ""
                    }
                    let dewPointNum = weather.currentWeather.dewPoint.converted(to: self.tempUnits).value
                    let dewPoint = dewPointNum.formatted(.number.precision(.fractionLength(0)))
                    let gustSpeed = weather.currentWeather.wind.gust?.converted(to: UnitSpeed.milesPerHour).value ?? 0.0
                    let windGust = gustSpeed.formatted(.number.precision(.fractionLength(0)))


                    self.feelsLike = "\( feelsLike )°"
                    self.currentTemperature = "\( temp )°"
                    self.currentCondition = weather.currentWeather.condition.description
                    self.currentHighTemp = "\( hi )°"
                    self.currentLowTemp = "\( lo )°"
                    self.dailyHighLowAbbrev = "H: \( self.currentHighTemp )  /  L: \( self.currentLowTemp )"
                    self.dailyHighLowFull = "High: \( self.currentHighTemp )  /  Low: \( self.currentLowTemp )"
                    self.currentHumidity = "\( humidity)%"
                    self.currentWindSpeed = "\( windSpeed ) mph"
                    self.currentWindDirection = "\(windDir)\(directionUnit) \(windFrom)"
                    self.asOf = weather.currentWeather.date
                    self.currentPressure = "\( pressure ) mb"
                    self.currentDewPoint = "\( dewPoint )°"
                    self.currentWindGust = "\( windGust ) mph"

                    //Hourly Format
                    weather.hourlyForecast.forecast.forEach { hour in
                        if self.hourlyForecast.count < 24 {
                            if self.isSameHourOrLater(date1: hour.date, date2: Date()) {
                                self.hourlyForecast.append(HourWeather(
                                    time: self.hourFormatter(date: hour.date),
                                    symbolName: hour.symbolName,
                                    temperature: "\( hour.temperature.converted(to: self.tempUnits).value.formatted(.number.precision(.fractionLength(0))) )°"
                                ))
                            }
                        }
                    }
                    
//                    //Daily Format
//                    weather.dailyForecast.forecast.forEach { day in
//                        self.tenDayForecast.append(DayWeather(
//                            day: self.dayFormatter(date: day.date),
//                            symbolName: day.symbolName,
//                            lowTemperature: "\( day.lowTemperature.formatted().dropLast() )",
//                            highTemperature: "\( day.highTemperature.formatted().dropLast() )"
//                        ))
//                    }

                    self.isLoading = false
                    print("Completed Fetching Weather...")
                }
            } catch {
                self.isLoading = false
                print("Error occurred fetching weather data: \(error.localizedDescription)")
            }
        }
    }
    
    func isSameHourOrLater(date1: Date, date2: Date) -> Bool {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "ha"
        
        let calendar = Calendar.current
        let comparisonResult = calendar.compare(date1, to: date2, toGranularity: .hour)
        
        return (comparisonResult == .orderedSame || comparisonResult == .orderedDescending)
    }

    func hourFormatter(date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "ha"
        
        let calendar = Calendar.current
        
        let inputDateComponents = calendar.dateComponents([.day,.hour], from: date)
        let currentDateComponents = calendar.dateComponents([.day,.hour], from: Date())
        
        return (inputDateComponents == currentDateComponents) ?"Now" :dateformatter.string(from: date)
    }

    func dayFormatter(date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "EEE"
        
        let calendar = Calendar.current
        
        let inputDateComponents = calendar.dateComponents([.day], from: date)
        let currentDateComponents = calendar.dateComponents([.day], from: Date())

        return (inputDateComponents == currentDateComponents) ?"Today" :dateformatter.string(from: date)
    }
}

struct HourWeather {
    let time: String
    let symbolName: String
    let temperature: String
}

struct DayWeather {
    let day: String
    let symbolName: String
    let lowTemperature: String
    let highTemperature: String
}

