//
//  AirQuality.swift
//  SajaWeather
//
//  Created by Milou on 8/6/25.
//

import Foundation

enum AirQuality: Int, CaseIterable {
  case good = 1
  case fair = 2
  case moderate = 3
  case poor = 4
  case veryPoor = 5
  
  var description: String {
    switch self {
    case .good:
      return "좋음"
    case .fair:
      return "보통"
    case .moderate:
      return "나쁨"
    case .poor:
      return "매우 나쁨"
    case .veryPoor:
      return "최악"
    }
  }
}
