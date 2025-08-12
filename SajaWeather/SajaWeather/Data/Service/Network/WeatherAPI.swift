//
//  WeatherAPI.swift
//  SajaWeather
//
//  Created by Milou on 8/7/25.
//

import Foundation
import Moya

enum WeatherAPI {
  case current(lat: Double, lon: Double, units: TemperatureUnit)
  case hourlyForecast(lat: Double, lon: Double, units: TemperatureUnit)
  case dailyForecast(lat: Double, lon: Double, units: TemperatureUnit)
  case airQuality(lat: Double, lon: Double)
}

extension WeatherAPI: TargetType {
  var baseURL: URL {
    return URL(string: "https://api.openweathermap.org/data/2.5")!
  }
  
  var path: String {
    switch self {
    case .current:
      return "/weather"
    case .hourlyForecast:
      return "/forecast/hourly"
    case .dailyForecast:
      return "/forecast/daily"
    case .airQuality:
      return "/air_pollution"
    }
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var task: Moya.Task {
    switch self {
    case .current(let lat, let lon, let units):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": units.rawValue,
          "lang": "kr"
        ],
        encoding: URLEncoding.queryString
      )
      
    case .hourlyForecast(let lat, let lon, let units):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": units.rawValue,
          "lang": "kr",
          "cnt": 24
        ],
        encoding: URLEncoding.queryString
      )
      
    case .dailyForecast(let lat, let lon, let units):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": units.rawValue,
          "lang": "kr",
          "cnt": 10
        ],
        encoding: URLEncoding.queryString
      )
      
    case .airQuality(let lat, let lon):
      return .requestParameters(
        parameters: ["lat": lat,
                     "lon": lon,
                     "appid": apiKey
                    ],
        encoding: URLEncoding.queryString)
    }
  }
  
  var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }
  
  var sampleData: Data {
    switch self {
    case .current:
      return stubData(from: "CurrentWeatherStub")
    case .hourlyForecast:
      return stubData(from: "HourlyForecastStub")
    case .dailyForecast:
      return stubData(from: "DailyForecastStub")
    case .airQuality:
      return stubData(from: "AirQualityStub")
    }
  }
}

extension WeatherAPI {
  private var apiKey: String {
    guard let key = Bundle.main.apiKey else {
      fatalError()
    }
    return key
  }
}

private func stubData(from fileName: String) -> Data {
  guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
        let data = try? Data(contentsOf: url) else {
    return Data()
  }
  return data
}
