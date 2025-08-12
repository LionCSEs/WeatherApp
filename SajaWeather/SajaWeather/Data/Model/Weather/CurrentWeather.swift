//
//  CurrentWeather.swift
//  SajaWeather
//
//  Created by Milou on 8/6/25.
//

import Foundation

struct CurrentWeather {
  let address: Location
  let temperature: Int
  let maxTemp: Int
  let minTemp: Int
  let feelsLikeTemp: Int
  let description: String
  let icon: Int // id
  let hourlyForecast: [HourlyForecast]
  let dailyForecast: [DailyForecast]
  let humidity: Int
  let windSpeed: Int
  let airQuality: AirQuality
  let sunrise: Date
  let sunset: Date
  let timeZone: TimeZone
}
