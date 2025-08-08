//
//  WeatherAPI.swift
//  SajaWeather
//
//  Created by Milou on 8/7/25.
//

import Foundation
import Moya

enum WeatherAPI {
  case current(lat: Double, lon: Double)
  case hourlyForecast(lat: Double, lon: Double)
  case dailyForecast(lat: Double, lon: Double)
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
    case .current(let lat, let lon):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": "metric", // 섭씨로 받아옴
          "lang": "kr"
        ],
        encoding: URLEncoding.queryString
      )
      
    case .hourlyForecast(let lat, let lon):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": "metric",
          "lang": "kr",
          "cnt" : 24
        ],
        encoding: URLEncoding.queryString
      )
      
    case .dailyForecast(let lat, let lon):
      return .requestParameters(
        parameters: [
          "lat": lat,
          "lon": lon,
          "appid": apiKey,
          "units": "metric",
          "lang": "kr",
          "cnt" : 10
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
  
  var headers: [String : String]? {
    return ["Content-Type": "application/json"]
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
