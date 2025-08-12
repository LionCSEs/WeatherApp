//
//  AppStep.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import Foundation
import RxFlow

enum AppStep: Step {
  case weatherDetailIsRequired(Location)
  case weatherListIsRequired
  case searchIsRequired
  case searchIsDismissed(Location?)
}
