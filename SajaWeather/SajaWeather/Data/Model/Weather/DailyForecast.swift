//
//  DailyForecast.swift
//  SajaWeather
//
//  Created by Milou on 8/6/25.
//

import Foundation

struct DailyForecast {
  let date: Date
  let humidity: Int
  let icon: Int // id
  let maxTemp: Int
  let minTemp: Int
  let sunrise: Date
  let sunset: Date
}
