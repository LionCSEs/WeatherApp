//
//  AppStep.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import Foundation
import RxFlow

enum AppStep: Step {
  case weatherDetailIsRequired(Coordinate)
  case weatherListIsRequired
  case searchIsRequired
  case searchIsDismissed(Coordinate?)
}
