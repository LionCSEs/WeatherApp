//
//  LocationSearchService.swift
//  SajaWeather
//
//  Created by Milou on 8/11/25.
//

import Foundation
import MapKit
import RxSwift
import CoreLocation

// MARK: - LocationSearchServiceType Protocol
protocol LocationSearchServiceType {
  func searchCompleter(query: String) -> Observable<[Location]>
  func searchDetail(completion: MKLocalSearchCompletion) -> Single<Location>
}

// MARK: - LocationSearchService Implementation
final class LocationSearchService: NSObject, LocationSearchServiceType {
  private let completer = MKLocalSearchCompleter()
  private var currentObserver: AnyObserver<[Location]>?
  
  override init() {
    super.init()
    setupCompleter()
  }
  
  private func setupCompleter() {
    completer.delegate = self
    completer.resultTypes = .address
  }
  
  // MARK: - 자동완성 검색
  func searchCompleter(query: String) -> Observable<[Location]> {
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onCompleted()
        return Disposables.create()
      }
            
      if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        observer.onNext([])
        observer.onCompleted()
        return Disposables.create()
      }
      
      // 현재 observer 저장
      self.currentObserver = observer.asObserver()
      
      // 검색 시작
      self.completer.queryFragment = query
      
      return Disposables.create {
        self.completer.cancel()
        self.currentObserver = nil
      }
    }
    .timeout(.seconds(10), scheduler: MainScheduler.instance)
  }
  
  // MARK: - 선택된 completion의 상세 정보 검색
  func searchDetail(completion: MKLocalSearchCompletion) -> Single<Location> {
    return Single.create { observer in
      
      let request = MKLocalSearch.Request(completion: completion)
      let search = MKLocalSearch(request: request)
      
      search.start { response, error in
        if let error = error {
          observer(.failure(error))
          return
        }
        
        guard let mapItem = response?.mapItems.first else {
          observer(.failure(LocationSearchError.noResults))
          return
        }
        
        let location = Location(
          title: mapItem.name ?? completion.title,
          subtitle: completion.subtitle,
          fullAddress: mapItem.placemark.title ?? "\(completion.subtitle) \(completion.title)",
          coordinate: mapItem.placemark.coordinate
        )
        
        observer(.success(location))
      }
      
      return Disposables.create {
        search.cancel()
      }
    }
  }
}

// MARK: - MKLocalSearchCompleterDelegate
extension LocationSearchService: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    
    let locations = completer.results.map { completion in
      Location(
        title: completion.title,
        subtitle: completion.subtitle,
        fullAddress: "\(completion.subtitle) \(completion.title)",
        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
      )
    }
    
    currentObserver?.onNext(locations)
    currentObserver?.onCompleted()
    currentObserver = nil
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    currentObserver?.onNext([])
    currentObserver?.onCompleted()
    currentObserver = nil
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
