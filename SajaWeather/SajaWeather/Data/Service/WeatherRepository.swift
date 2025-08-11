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
  /// 특정 위치의 현재 날씨 정보를 가져옵니다
  /// - Parameters:
  ///   - coordinate: 날씨를 조회할 위치 좌표
  ///   - units: 온도 단위 (섭씨: .celsius, 화씨: .fahrenheit)
  /// - Returns: 현재 날씨 정보를 포함한 Single 스트림
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
