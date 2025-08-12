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
    case changeBackgroundStyle(GradientStyle)
  }
  
  enum Mutation {
    case setLayoutType(LayoutType)
    case setTempUnit(TemperatureUnit)
    case setWeatherItems([WeatherListItem])
    case setBackgroundStyle(GradientStyle)
  }
  
  struct State {
    var layoutType: LayoutType = .grid
    var tempUnit: TemperatureUnit
    var weatherItems: [WeatherListItem] = []
    var backgroundStyle: GradientStyle = .unknown
  }
  
  let initialState: State
  
  private let weatherRepository: WeatherRepositoryType
  
  init(weatherRepository: WeatherRepositoryType) {
    self.initialState = State(
      tempUnit: TemperatureUnit(rawValue: UserDefaultsService.shared.loadTemperatureUnit())!
    )
    self.weatherRepository = weatherRepository
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loadWeather:
      return loadWeatherItems(unit: currentState.tempUnit)

    case .toggleLayout:
      let newLayoutType: LayoutType = currentState.layoutType == .grid ? .list : .grid
      return .just(.setLayoutType(newLayoutType))
      
    case .toggleTempUnit:
      let newTempUnit: TemperatureUnit = currentState.tempUnit == .celsius ? .fahrenheit : .celsius
      return Observable.concat([
        .just(.setTempUnit(newTempUnit)),
        loadWeatherItems(unit: newTempUnit)
      ])
      
    case let .changeBackgroundStyle(style):
      return .just(.setBackgroundStyle(style))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setLayoutType(let layoutType):
      state.layoutType = layoutType
      state.backgroundStyle = layoutType == .grid ? state.weatherItems.first?.weatherData.backgroundStyle ?? .unknown : .unknown
    case .setTempUnit(let tempUnit):
      state.tempUnit = tempUnit
    case .setWeatherItems(let weatherItems):
      state.weatherItems = weatherItems
      state.backgroundStyle = currentState.layoutType == .grid ? weatherItems.first?.weatherData.backgroundStyle ?? .unknown : .unknown
    case let .setBackgroundStyle(style):
      state.backgroundStyle = style
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
  
  private func loadWeatherItems(unit: TemperatureUnit) -> Observable<Mutation> {
    var locations = UserDefaultsService.shared.loadSavedLocation()
    
    if locations.isEmpty {
      locations = [SavedLocation(name: "서울", lat: 37.5665, lon: 126.9780)]
    }
    
    return Observable.from(locations)
      .flatMap {location -> Observable<WeatherListItem> in
        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        return self.weatherRepository
          .getCurrentWeather(coordinate: coordinate, units: unit)
          .asObservable()
          .map {WeatherListItem(weatherData: $0)}
      }
      .toArray()
      .asObservable()
      .map { .setWeatherItems($0) }
  }
}
