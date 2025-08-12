//
//  TemperatureUnit.swift
//  SajaWeather
//
//  Created by Milou on 8/11/25.
//

import Foundation

enum TemperatureUnit: String, CaseIterable {
  case celsius = "metric"
  case fahrenheit = "imperial"
  
  var symbol: String {
    switch self {
    case .celsius: return "C"
    case .fahrenheit: return "F"
    }
  }
}
