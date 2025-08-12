//
//  WeatherDTO.swift
//  SajaWeather
//
//  Created by Milou on 8/7/25.
//

import Foundation

struct CurrentWeatherResponseDTO: Codable {
  let coord: CoordinateDTO
  let weather: [WeatherDetailDTO]
  let main: MainWeatherDTO
  let wind: WindDTO
  let sys: SysDTO
  let timezone: Int
  let name: String
}

// MARK: - Hourly Forecast Response

struct HourlyForecastResponseDTO: Codable {
  let list: [HourlyItemDTO]
}

struct HourlyItemDTO: Codable {
  let dt: Int // hour
  let main: MainWeatherDTO
  let weather: [WeatherDetailDTO]
}

// MARK: - Daily Forecast Response

struct DailyForecastResponseDTO: Codable {
  let city: CityDTO?
  let list: [DailyItemDTO]
}

struct CityDTO: Codable {
  let timezone: Int?
}

struct DailyItemDTO: Codable {
  let dt: Int // unix
  let temp: DailyTempDTO
  let weather: [WeatherDetailDTO]
  let humidity: Int
  let sunrise: Int
  let sunset: Int
}

struct DailyTempDTO: Codable {
  let min: Double
  let max: Double
}

// MARK: - Air Quality Response

struct AirQualityResponseDTO: Codable {
  let list: [AirQualityItemDTO]
}

struct AirQualityItemDTO: Codable {
  let main: AirQualityMainDTO
}

struct AirQualityMainDTO: Codable {
  let aqi: Int
}

// MARK: - Common DTOs

struct CoordinateDTO: Codable {
  let lon: Double
  let lat: Double
}

struct WeatherDetailDTO: Codable {
  let id: Int // icon
  let main: String
  let description: String
}

struct MainWeatherDTO: Codable {
  let temp: Double
  let feelsLike: Double
  let tempMin: Double
  let tempMax: Double
  let humidity: Int
  
  enum CodingKeys: String, CodingKey {
    case temp
    case feelsLike = "feels_like"
    case tempMin = "temp_min"
    case tempMax = "temp_max"
    case humidity
  }
}

struct WindDTO: Codable {
  let speed: Double
}

struct SysDTO: Codable {
  let sunrise: Int
  let sunset: Int
}
