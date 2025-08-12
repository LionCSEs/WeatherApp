//
//  WeatherListItem.swift
//  SajaWeather
//
//  Created by estelle on 8/11/25.
//

import Foundation

struct WeatherListItem: Hashable {
  let id = UUID()
  let weatherData: CurrentWeather
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: WeatherListItem, rhs: WeatherListItem) -> Bool {
    lhs.id == rhs.id
  }
}

enum WeatherListSection: CaseIterable {
  case main
}
