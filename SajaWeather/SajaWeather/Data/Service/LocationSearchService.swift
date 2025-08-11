//
//  LocationSearchService.swift
//  SajaWeather
//
//  Created by Milou on 8/11/25.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift
import CoreLocation

protocol LocationSearchServiceType {
  /// "사직동" 입력 -> [종로구 사직동, 동래구 사직동 ...] 자동완성 제안
  func searchCompleter(query: String) -> Observable<[Location]>
  
  /// "종로구 사직동" 선택 -> 정확한 주소 및 좌표 반환
  func searchDetail(completion: MKLocalSearchCompletion) -> Single<Location>
}

final class LocationSearchService: NSObject, LocationSearchServiceType {
  
  private let completer = MKLocalSearchCompleter()
  private var searchObserver: AnyObserver<[Location]>?
  
  override init() {
    super.init()
    setupCompleter()
  }
  
  private func setupCompleter() {
    completer.resultTypes = .address
  }
  
  // MARK: - 자동완성 검색
  
  func searchCompleter(query: String) -> Observable<[Location]> {
    
    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return Observable.just([])
    }
    
    return completer.rx.query(query)
      .map { completions in
        completions.map { completion in
          Location(
            title: completion.title,
            subtitle: completion.subtitle,
            fullAddress: "\(completion.subtitle) \(completion.title)",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
          )
        }
      }
    .timeout(.seconds(5), scheduler: MainScheduler.instance)
    .catch { error in
      return Observable.just([])
    }
  }
  
  // MARK: - 선택된 위치에 대한 상세 정보 검색
  
  func searchDetail(completion: MKLocalSearchCompletion) -> Single<Location> {
    return completion.rx.localSearch()
      .map { response in
        guard let mapItem = response.mapItems.first else {
          throw LocationSearchError.noResults
        }
        
        let location = Location(
          title: mapItem.name ?? completion.title,
          subtitle: completion.subtitle,
          fullAddress: mapItem.placemark.title ?? "\(completion.subtitle) \(completion.title)",
          coordinate: mapItem.placemark.coordinate
        )
        return location
      }
      .asSingle()
  }
}

// MARK: - LocationSearchError

enum LocationSearchError: LocalizedError {
  case noResults
  case unknown
  
  var errorDescription: String? {
    switch self {
    case .noResults:
      return "검색 결과가 없습니다"
    case .unknown:
      return "검색 중 오류가 발생했습니다"
    }
  }
}

extension Reactive where Base: MKLocalSearchCompleter {
  var delegate: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate> {
    return RxLocalSearchCompleterDelegateProxy.proxy(for: base)
  }

  func setDelegate(_ delegate: MKLocalSearchCompleterDelegate) -> Disposable {
    return RxLocalSearchCompleterDelegateProxy.installForwardDelegate(
      delegate,
      retainDelegate: false,
      onProxyForObject: base
    )
  }

  func query(_ query: String) -> Observable<[MKLocalSearchCompletion]> {
    return delegate
      .methodInvoked(#selector(MKLocalSearchCompleterDelegate.completerDidUpdateResults(_:)))
      .compactMap { $0[0] as? MKLocalSearchCompleter }
      .map(\.results)
      .do(onSubscribe: { [base] in
        base.queryFragment = query
      }, onDispose: { [base] in
        base.cancel()
      })
  }
}

extension Reactive where Base: MKLocalSearchCompletion {
  func localSearch() -> Observable<MKLocalSearch.Response> {
    return Observable.create { [base] observer in
      let search = MKLocalSearch(request: MKLocalSearch.Request(completion: base))
      search.start { response, error in
        if let error = error {
          observer.on(.error(error))
        } else if let response = response {
          observer.on(.next(response))
          observer.on(.completed)
        }
      }
      return Disposables.create {
        search.cancel()
      }
    }
  }
}

// 프록시 먼저 만들기
final class RxLocalSearchCompleterDelegateProxy: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate>, DelegateProxyType, MKLocalSearchCompleterDelegate {
  static func registerKnownImplementations() {
    register {
      RxLocalSearchCompleterDelegateProxy(
        parentObject: $0,
        delegateProxy: RxLocalSearchCompleterDelegateProxy.self
      )
    }
  }

  static func currentDelegate(for object: MKLocalSearchCompleter) -> MKLocalSearchCompleterDelegate? {
    return object.delegate
  }

  static func setCurrentDelegate(_ delegate: MKLocalSearchCompleterDelegate?, to object: MKLocalSearchCompleter) {
    object.delegate = delegate
  }
}
