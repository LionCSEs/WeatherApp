//
//  WeatherService.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation
import RxSwift
import RxMoya
import Moya
import CoreLocation

protocol WeatherServiceType {
  func getCurrentWeather(coordinate: CLLocationCoordinate2D) -> Observable<CurrentWeather>
}

final class WeatherService: WeatherServiceType {
  
  private let provider: MoyaProvider<WeatherAPI>
  
  init(provider: MoyaProvider<WeatherAPI> = MoyaProvider<WeatherAPI>()) {
    self.provider = provider
  }
  
  static var stubProvider: MoyaProvider<WeatherAPI> {
    return MoyaProvider<WeatherAPI>(
      stubClosure: MoyaProvider.immediatelyStub
    )
  }
  
  func getCurrentWeather(coordinate: CLLocationCoordinate2D) -> Observable<CurrentWeather> {
    let lat = coordinate.latitude
    let lon = coordinate.longitude
    
    let currentWeatherObservable = provider.rx
      .request(.current(lat: lat, lon: lon))
      .map(CurrentWeatherResponseDTO.self)
      .asObservable()
    
    let hourlyForecastObservable = provider.rx
      .request(.hourlyForecast(lat: lat, lon: lon))
      .map(HourlyForecastResponseDTO.self)
      .asObservable()
    
    let dailyForecastObservable = provider.rx
      .request(.dailyForecast(lat: lat, lon: lon))
      .map(DailyForecastResponseDTO.self)
      .asObservable()
    
    let airQualityObservable = provider.rx
      .request(.airQuality(lat: lat, lon: lon))
      .map(AirQualityResponseDTO.self)
      .asObservable()
    
    return Observable.zip(
      currentWeatherObservable,
      hourlyForecastObservable,
      dailyForecastObservable,
      airQualityObservable
    ) { current, hourly, daily, airQuality in
      CurrentWeather(
        currentWeather: current,
        hourlyForecast: hourly,
        dailyForecast: daily,
        airQuality: airQuality,
        coordinate: coordinate
      )
    }
    .catch { error in
      return Observable.error(error)
    }
  }
}

