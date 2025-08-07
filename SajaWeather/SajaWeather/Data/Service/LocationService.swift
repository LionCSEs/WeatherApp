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

// 의존성 주입을 위한 추상화 - Stub을 써서 가짜 위치를 반환할 수도 있게
protocol LocationServiceType {
  func getLocation() -> Observable<CLLocation>
}

final class LocationService: LocationServiceType {
  private let manager = CLLocationManager()
  
  // 뷰모델 등에서 호출해 Rx 방식으로 위치를 받아오는 메서드
  func getLocation() -> Observable<CLLocation> {
    
    // RxSwift 확장 기능을 통해 위치 권한을 요청해 Observable<CLAuthorizationStatus>로 리턴받음
    let requestAuthorization = manager.rx.requestWhenInUseAuthorization()
    
    // 위치 요청해 [CLLocation] 형태로 수신. 그것을 아래처럼 처리
    let requestLocation = manager.rx.requestLocations()
      .compactMap(\.last) // [CLLocation] 값 중 마지막 값
      .timeout(.seconds(10), scheduler: MainScheduler.instance) // 10초 이내에 응답받지 못한 경우
      .catch { _ in Observable.error(LocationError.timeout) } // .timeout 에러 방출 (앱 멈춤 방지)
      .take(1) // 처음 emit된 한 번의 위치만 받고 스트림 종료
    
    // 권한 상태에 따른 분기 처리 (허용 시 위치 요청, 거부 또는 제한 시 해당 LocationError 발생)
    return requestAuthorization
      .flatMap { status -> Observable<CLLocation> in
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
          return requestLocation
        case .denied:
          return .error(LocationError.authorizationDenied)
        case .restricted:
          return .error(LocationError.authorizationRestricted)
        default:
          return .error(LocationError.unknown)
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
