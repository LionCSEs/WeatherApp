//
//  WeatherServiceStub.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation
import RxSwift
import CoreLocation
import RxMoya
import Moya

final class WeatherServiceStub: WeatherServiceType {
  func getCurrentWeather(location: Location, units: TemperatureUnit) -> Single<CurrentWeather> {
    
    let stubProvider = MoyaProvider<WeatherAPI>(stubClosure: MoyaProvider.immediatelyStub)
    let weatherService = WeatherService(provider: stubProvider)
    return weatherService.getCurrentWeather(location: location, units: units)
    
  }
}
