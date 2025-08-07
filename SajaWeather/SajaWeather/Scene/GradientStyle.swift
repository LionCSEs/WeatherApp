//
//  GradientStyle.swift
//  SajaWeather
//
//  Created by estelle on 8/7/25.
//

import UIKit

enum GradientStyle {
  case clearDay
  case clearNight
  case cloudyDay
  case cloudyNight
  case rainyDay
  case rainyNight
  case snowyDay
  case snowyNight
  case thunderDay
  case thunderNight
  
  var colors: [UIColor] {
    switch self {
    case .clearDay:
      return [.clearDayTop, .clearDayBottom]
    case .clearNight:
      return [.clearNightTop, .clearNightBottom]
    case .cloudyDay:
      return [.cloudyAndRainyDayTop, .cloudyDayBottom]
    case .cloudyNight:
      return [.cloudyNightTop, .cloudyNightBottom]
      case .rainyDay:
      return [.cloudyAndRainyDayTop, .rainyDayBottom]
    case .rainyNight:
      return [.rainyNightTop, .rainyNightBottom]
    case .snowyDay:
      return [.snowyDayTop, .snowyDayBottom]
    case .snowyNight:
      return [.snowyNightTop, .snowyNightBottom]
      case .thunderDay:
      return [.thunderDayTop, .thunderDayBottom]
    case .thunderNight:
      return [.thunderNightTop, .thunderNightBottom]
    }
  }
}
