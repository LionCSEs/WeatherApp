//
//  LocationServiceStub.swift
//  SajaWeather
//
//  Created by 김우성 on 8/7/25.
//

import RxSwift
import CoreLocation

//final class LocationServiceStub: LocationServiceType {
//  private let location: CLLocation?
//  private let error: LocationError?
//  private let delay: RxTimeInterval
//  
//  init(
//    location: CLLocation? = CLLocation(latitude: 37.5665, longitude: 126.9780), // 서울시청
//    error: LocationError? = nil,
//    delay: RxTimeInterval = .milliseconds(100)
//  ) {
//    self.location = location
//    self.error = error
//    self.delay = delay
//  }
//  
//  func getLocation() -> Observable<CLLocation> {
//    if let error = error {
//      return Observable<CLLocation>.error(error)
//        .delay(delay, scheduler: MainScheduler.instance)
//    } else if let location = location {
//      return Observable.just(location)
//        .delay(delay, scheduler: MainScheduler.instance)
//    } else {
//      return Observable.error(LocationError.unknown)
//        .delay(delay, scheduler: MainScheduler.instance)
//    }
//  }
//}

/// 사용 시
/// 위치를 잘 받았다는 가정
//  let stub = LocationServiceStub()
//  let viewModel = WeatherDetailViewModel(locationService: stub)

/// 접근을 허용받지 못했다는 가정
//  let stub = LocationServiceStub(error: .authorizationDenied)
//  let viewModel = WeatherDetailViewModel(locationService: stub)
