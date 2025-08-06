//
//  LocationService.swift
//  SajaWeather
//
//  Created by 김우성 on 8/6/25.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

// 날씨 정보 받아오라는 액션 -> 권한 확인 -> 위치 정보 수신 -> 날씨 요청
// 으로 변경 예정

final class LocationService {
  static let shared = LocationService()
  
  private let manager = CLLocationManager()
  private let disposeBag = DisposeBag()
  
  private init() {}
  
  enum LocationError: Error {
    case authorizationDenied
  }
  
  // 싱글톤 패턴으로 얘를 구독해서 CLLocation 값을 얻으시면 됩니다.
  func getLocation() -> Observable<CLLocation> {
    let requestAuthorization = manager.rx.requestWhenInUseAuthorization()
    let requestLocations = manager.rx.requestLocations()
      .compactMap(\.last)
      .first()
      .compactMap { $0 }
    
    return requestAuthorization
      .flatMap { status -> Observable<CLLocation> in
        if status == .authorizedWhenInUse || status == .authorizedAlways {
          return requestLocations.asObservable()
        } else {
          return .error(LocationError.authorizationDenied)
        }
      }
  }
}

// MARK: - CLLocationManager (Reactive)

extension Reactive where Base: CLLocationManager {
  var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base)
  }
  
  func setDelegate(_ delegate: CLLocationManagerDelegate) -> Disposable {
    return RxCLLocationManagerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
  }
  
  func requestWhenInUseAuthorization() -> Observable<CLAuthorizationStatus> {
    let requestAuthorization = delegate
      .methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)))
      .compactMap { $0[0] as? CLLocationManager }
      .map(\.authorizationStatus)
      .do(onSubscribe: { [base] in
        base.requestWhenInUseAuthorization()
      })
      .startWith(base.authorizationStatus) // 기존 상태도 반영하되, 결정 안 됐으면 대기
      .distinctUntilChanged()
      .filter { $0 != .notDetermined } // 결정된 이후에만 emit
      .take(1)
    return Observable
      .create { [base] observer in
        observer.on(.next(base.authorizationStatus))
        observer.on(.completed)
        return Disposables.create()
      }
      .flatMapFirst { status in
        switch status {
        case .notDetermined:
          return requestAuthorization
        default:
          return .just(status)
        }
      }
  }
  
  func requestLocations() -> Observable<[CLLocation]> {
    return delegate
      .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
      .compactMap { $0[1] as? [CLLocation] }
      .do(onSubscribe: { [base] in
        base.startUpdatingLocation()
      }, onDispose: { [base] in
        base.stopUpdatingLocation()
      })
  }
}

// MARK: - RxCLLocationManagerDelegateProxy

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
  static func registerKnownImplementations() {
    register {
      RxCLLocationManagerDelegateProxy(parentObject: $0, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
  }
  
  static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
    return object.delegate
  }
  
  static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
    object.delegate = delegate
  }
}
