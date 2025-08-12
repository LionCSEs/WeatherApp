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
  case unknown
  
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
      case .unknown:
      return [UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1), UIColor(red: 183/255, green: 183/255, blue: 183/255, alpha: 1)]
    }
  }
}
