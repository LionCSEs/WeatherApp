//
//  WeatherDetailReactor.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import RxSwift
import RxRelay
import ReactorKit
import CoreLocation
import Then

final class WeatherDetailReactor : Reactor {
  struct State: Then {
    var selectedLocation: Location?
    @Pulse var location: CLLocation?
    var currentWeather: CurrentWeather?
    var isLoading: Bool = false
    @Pulse var error: LocationError?
  }
  
  enum Action {
    case requestLocation
    case requestWeather
  }
  
  enum Mutation {
    case setLocation(CLLocation)
    case setCurrentWeather(CurrentWeather)
    case setLoading(Bool)
    case setError(LocationError)
    case clearError
  }
  
  let initialState: State

  private let locationService: LocationServiceType
  private let weatherRepository: WeatherRepositoryType
  private let unitsDefault: TemperatureUnit
  
  init(
    locationService: LocationServiceType,
    weatherRepository: WeatherRepositoryType,
    location: Location?,
  ) {
    self.initialState = State(selectedLocation: location)
    self.locationService = locationService
    self.weatherRepository = weatherRepository
    self.unitsDefault = UserDefaultsService.shared.loadTemperatureUnitEnum()
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .requestLocation:
      return locationService
        .getLocation()
        .map(Mutation.setLocation)
        .catch { error in
          let e = (error as? LocationError) ?? .unknown
          return .just(.setError(e))
        }
      
    case .requestWeather:
      let locationObservable: Observable<Location> = if let location = currentState.selectedLocation {
        .just(location)
      } else {
        locationService.getLocation()
          .flatMap { [locationService] in locationService.reverseGeocode($0) }
      }
      let currentWeather = locationObservable
        .flatMap { [weatherRepository, unitsDefault] location in
          weatherRepository.getCurrentWeather(location: location, units: unitsDefault)
        }
      return .concat(
        .just(.setLoading(true)),
        currentWeather.map { .setCurrentWeather($0) },
        .just(.setLoading(false))
      )

//      weatherRepository.getCurrentWeather(location: <#T##Location#>, units: unitsDefault)
//      let resolveLocation: Observable<Location> = {
//        // 현재 위치가 있으면 역지오코딩으로 Location 생성
//        if let location = currentState.location {
//          return locationService.reverseGeocode(location)
//        }
//        // 현재 위치가 없으면 위치 가져온 후 역지오코딩
//        return locationService.getLocation()
//          .flatMap { [locationService] clLocation in
//            locationService.reverseGeocode(clLocation)
//          }
//      }()
//
//      let request = resolveLocation
//        .flatMapLatest { [weatherRepository] location in
//          weatherRepository.getCurrentWeather(
//            location: location,
//            units: units
//          ).asObservable()
//        }
//        .map(Mutation.setCurrentWeather)
//        .catch { error in
//          let e = (error as? LocationError) ?? .unknown
//          return .just(.setError(e))
//        }
//
//      return .concat(
//        .just(.clearError),
//        .just(.setLoading(true)),
//        request,
//        .just(.setLoading(false))
//      )
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .setLocation(let loc):
      newState.location = loc
    case .setCurrentWeather(let cw):
      newState.currentWeather = cw
    case .setLoading(let loading):
      newState.isLoading = loading
    case .setError(let err):
      newState.error = err
      newState.isLoading = false
    case .clearError:
      newState.error = nil
    }
    return newState
  }
}
