//
//  WeatherRepository.swift
//  SajaWeather
//
//  Created by Milou on 8/11/25.
//

import Foundation
import RxSwift
import CoreLocation

protocol WeatherRepositoryType {
  var temperatureUnit: TemperatureUnit { get set }
  func getCurrentWeather(coordinate: CLLocationCoordinate2D) -> Single<CurrentWeather>
}

final class WeatherRepository: WeatherRepositoryType {
  var temperatureUnit: TemperatureUnit = .celsius
  
  private let weatherService: WeatherServiceType
  
  init(weatherService: WeatherServiceType) {
    self.weatherService = weatherService
  }
  
  func getCurrentWeather(coordinate: CLLocationCoordinate2D) -> Single<CurrentWeather> {
    return weatherService.getCurrentWeather(coordinate: coordinate, units: temperatureUnit)
  }
}
