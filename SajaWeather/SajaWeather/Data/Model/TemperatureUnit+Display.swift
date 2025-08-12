//
//  TemperatureUnit+Display.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import Foundation

extension TemperatureUnit {
  var symbol: String {
    switch self {
    case .celsius:    return "C"
    case .fahrenheit: return "F"
    }
  }
}
