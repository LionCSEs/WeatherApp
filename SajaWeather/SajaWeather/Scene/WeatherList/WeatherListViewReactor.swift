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
    case changeBackgroundStyle(GradientStyle)
  }
  
  enum Mutation {
    case setLayoutType(LayoutType)
    case setTempUnit(TemperatureUnit)
    case setWeatherItems([WeatherListItem])
    case setShouldPresentPlus(Bool)
    case setBackgroundStyle(GradientStyle)
  }
  
  struct State {
    var layoutType: LayoutType = .grid
    var tempUnit: TemperatureUnit
    var weatherItems: [WeatherListItem] = []
    var backgroundStyle: GradientStyle = .unknown
    var shouldPresentPlus: Bool = false
  }
  
  let initialState: State
  
  //private let weatherService: WeatherService
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
      //      let mockData = [
      //        WeatherListItem(weatherData: CurrentWeather(
      //          address: Location(title: "", subtitle: "", fullAddress: "서울시 강남구",
      //                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
      //          temperature: 30, maxTemp: 35, minTemp: 30, feelsLikeTemp: 30,
      //          description: "맑음", icon: 201, hourlyForecast: [], dailyForecast: [],
      //          humidity: 0, windSpeed: 0, airQuality: .fair, sunrise: Date(), sunset: Date()
      //        )),
      //        WeatherListItem(weatherData: CurrentWeather(
      //          address: Location(title: "", subtitle: "", fullAddress: "서울시 강남구",
      //                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
      //          temperature: 30, maxTemp: 40, minTemp: 30, feelsLikeTemp: 30,
      //          description: "흐림", icon: 601, hourlyForecast: [], dailyForecast: [],
      //          humidity: 0, windSpeed: 0, airQuality: .fair, sunrise: Date(), sunset: Date()
      //        ))
      //      ]
      //      return .just(.setWeatherItems(mockData))
      
    case .toggleLayout:
      let newLayoutType: LayoutType = currentState.layoutType == .grid ? .list : .grid
      return .just(.setLayoutType(newLayoutType))
      
    case .toggleTempUnit:
      let newTempUnit: TemperatureUnit = currentState.tempUnit == .celsius ? .fahrenheit : .celsius
      return Observable.concat([
        .just(.setTempUnit(newTempUnit)),
        loadWeatherItems(unit: newTempUnit)
      ])
      
    case .plusButtonTapped:
      return .concat([
        .just(.setShouldPresentPlus(true)),
        .just(.setShouldPresentPlus(false))
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
      state.backgroundStyle = weatherItems.first?.weatherData.backgroundStyle ?? .unknown
      //print(weatherItems)
    case .setShouldPresentPlus(let shouldPresentPlus):
      state.shouldPresentPlus = shouldPresentPlus
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
    var savedLocations = UserDefaultsService.shared.loadSavedLocation()
    
    if savedLocations.isEmpty {
      savedLocations = [SavedLocation(name: "서울", lat: 37.5665, lon: 126.9780)]
    }
    
    return Observable.from(savedLocations)
      .flatMap { savedLocation -> Observable<WeatherListItem> in
        
        let location = Location(
          title: savedLocation.name,
          subtitle: savedLocation.name,
          fullAddress: savedLocation.name,
          coordinate: Coordinate(latitude: savedLocation.lat, longitude: savedLocation.lon)
        )
        
        return self.weatherRepository
          .getCurrentWeather(location: location, units: unit)
          .asObservable()
          .map {WeatherListItem(weatherData: $0)}
      }
      .toArray()
      .asObservable()
      .map { .setWeatherItems($0) }
  }
}
