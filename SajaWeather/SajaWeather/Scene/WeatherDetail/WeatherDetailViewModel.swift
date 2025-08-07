//
//  WeatherDetailViewModel.swift
//  SajaWeather
//
//  Created by 김우성 on 8/7/25.
//

import RxSwift
import RxRelay
import CoreLocation

final class WeatherDetailViewModel {
  struct State {
    var location: CLLocation?
    var error: LocationError?
  }
  
  enum Action {
    case requestLocation
  }
  
  let stateRelay = BehaviorRelay(value: State())
  let action = PublishRelay<Action>()
  
  private let locationService: LocationServiceType
  private let disposeBag = DisposeBag()
  
  init(locationService: LocationServiceType) {
    self.locationService = locationService
    
    action
      .flatMapLatest { [locationService] action -> Observable<CLLocation> in
        guard action == .requestLocation else { return .empty() }
        return locationService.getLocation()
      }
      .subscribe(
        onNext: { [stateRelay] location in
          var state = stateRelay.value
          state.location = location
          state.error = nil
          stateRelay.accept(state)
        },
        onError: { [stateRelay] error in
          var state = stateRelay.value
          let locError = error as? LocationError ?? .unknown
          state.error = locError
          state.location = nil
          stateRelay.accept(state)
        }
      )
      .disposed(by: disposeBag)
  }
}
