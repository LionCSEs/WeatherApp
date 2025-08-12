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
  func reverseGeocode(_ location: CLLocation) -> Observable<Location>
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
  
  func reverseGeocode(_ location: CLLocation) -> Observable<Location> {
      return Observable.create { observer in
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
          if let error = error {
            // 실패해도 기본값으로 Location 생성
            let fallbackLocation = Location(
              title: "현재 위치",
              subtitle: "현재 위치",
              fullAddress: "현재 위치",
              coordinate: location.coordinate
            )
            observer.onNext(fallbackLocation)
            observer.onCompleted()
            return
          }
          
          guard let placemark = placemarks?.first else {
            let fallbackLocation = Location(
              title: "현재 위치",
              subtitle: "현재 위치",
              fullAddress: "현재 위치",
              coordinate: location.coordinate
            )
            observer.onNext(fallbackLocation)
            observer.onCompleted()
            return
          }
          
          let resolvedLocation = Location(
            title: placemark.subLocality ?? placemark.locality ?? "현재 위치", // 상암동
            subtitle: placemark.locality ?? placemark.administrativeArea ?? "현재 위치",
            fullAddress: [
              placemark.locality ?? placemark.administrativeArea,  // "서울특별시"
              placemark.subLocality  // "상암동"
            ].compactMap { $0 }.joined(separator: " "),  // "서울특별시 상암동"
            coordinate: location.coordinate
          )
          
          observer.onNext(resolvedLocation)
          observer.onCompleted()
        }
        
        return Disposables.create {
          geocoder.cancelGeocode()
        }
      }
    }
}

// MARK: - CLLocationManager (Reactive)

extension Reactive where Base: CLLocationManager {
  // delegate 메서드 (콜백)으로만 소통하는 CLLocationManager
  // 매니저가 delegate 메서드를 호출하면 프록시가 호출을 Rx 이벤트로 변환
  var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
    return RxCLLocationManagerDelegateProxy.proxy(for: base)
  }
  
  // delegate를 프록시에 설치
  func setDelegate(_ delegate: CLLocationManagerDelegate) -> Disposable {
    return RxCLLocationManagerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
  }
  
  // 현재 권한 상태를 확인
  // 확인됐다면 -> 바로 내보냄
  // 아직 권한을 묻지 않았다면(.notDetermined라면) -> 권한 팝업을 띄움. 권한이 바뀌었다는 콜백이 들어오면 딱 한번 값을 내보내고 종료
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
