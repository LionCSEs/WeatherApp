//
//  WeatherRepository.swift
//  SajaWeather
//
//  Created by Milou on 8/11/25.
//

import Foundation
import RxSwift
import CoreLocation

typealias Coordinate = CLLocationCoordinate2D

protocol WeatherRepositoryType {
  func getCurrentWeather(coordinate: Coordinate, units: TemperatureUnit) -> Single<CurrentWeather>
}

final class WeatherRepository: WeatherRepositoryType {
  
  private let weatherService: WeatherServiceType
  
  init(weatherService: WeatherServiceType) {
    self.weatherService = weatherService
  }
  
  func getCurrentWeather(coordinate: Coordinate, units: TemperatureUnit) -> Single<CurrentWeather> {
    return weatherService.getCurrentWeather(coordinate: coordinate, units: units)
  }
}
