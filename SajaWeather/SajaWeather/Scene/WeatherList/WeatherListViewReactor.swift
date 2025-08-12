//
//  WeatherListViewReactor.swift
//  SajaWeather
//
//  Created by estelle on 8/12/25.
//

import RxSwift
import ReactorKit
import CoreLocation

enum LayoutType {
  case grid
  case list
}

final class WeatherListViewReactor: Reactor {
  enum Action {
    case loadWeather
    case toggleLayout
    case toggleTempUnit
    case plusButtonTapped
  }
  
  enum Mutation {
    case setLayoutType(LayoutType)
    case setTempUnit(TemperatureUnit)
    case setWeatherItems([WeatherListItem])
    case setShouldPresentPlus(Bool)
  }
  
  struct State {
    var layoutType: LayoutType = .grid
    var tempUnit: TemperatureUnit
    var weatherItems: [WeatherListItem] = []
    var backgroundStyle: GradientStyle = .clearDay
    var shouldPresentPlus: Bool = false
  }
  
  let initialState: State
  
  private let weatherService: WeatherService
  
  init(WeatherService: WeatherService) {
    self.initialState = State(
      tempUnit: TemperatureUnit(rawValue: UserDefaultsService.shared.loadTemperatureUnit())!
    )
    self.weatherService = WeatherService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loadWeather:
      let mockData = [
        WeatherListItem(weatherData: CurrentWeather(
          address: Location(title: "", subtitle: "", fullAddress: "서울시 강남구",
                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
          temperature: 30, maxTemp: 35, minTemp: 30, feelsLikeTemp: 30,
          description: "맑음", icon: 201, hourlyForecast: [], dailyForecast: [],
          humidity: 0, windSpeed: 0, airQuality: .fair, sunrise: Date(), sunset: Date()
        )),
        WeatherListItem(weatherData: CurrentWeather(
          address: Location(title: "", subtitle: "", fullAddress: "서울시 강남구",
                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
          temperature: 30, maxTemp: 40, minTemp: 30, feelsLikeTemp: 30,
          description: "흐림", icon: 9, hourlyForecast: [], dailyForecast: [],
          humidity: 0, windSpeed: 0, airQuality: .fair, sunrise: Date(), sunset: Date()
        ))
      ]
      return .just(.setWeatherItems(mockData))
    case .toggleLayout:
      let newLayoutType: LayoutType = self.currentState.layoutType == .grid ? .list : .grid
      return .just(.setLayoutType(newLayoutType))
    case .toggleTempUnit:
      let newTempUnit: TemperatureUnit = self.currentState.tempUnit == .celsius ? .fahrenheit : .celsius
      return .just(.setTempUnit(newTempUnit))
    case .plusButtonTapped:
      return .concat([
        .just(.setShouldPresentPlus(true)),
        .just(.setShouldPresentPlus(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setLayoutType(let layoutType):
      state.layoutType = layoutType
      state.backgroundStyle = layoutType == .grid ? state.weatherItems.first?.weatherData.backgroundStyle ?? .clearDay : .unknown
    case .setTempUnit(let tempUnit):
      state.tempUnit = tempUnit
    case .setWeatherItems(let weatherItems):
      state.weatherItems = weatherItems
      if let firstWeather = weatherItems.first?.weatherData {
        state.backgroundStyle = firstWeather.backgroundStyle
      }
    case .setShouldPresentPlus(let shouldPresentPlus):
      state.shouldPresentPlus = shouldPresentPlus
    }
    
    return state
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return mutation.do(onNext: { mutation in
      if case let .setTempUnit(unit) = mutation {
        UserDefaultsService.shared.saveTemperatureUnit(unit.rawValue)
      }
    })
  }
}
