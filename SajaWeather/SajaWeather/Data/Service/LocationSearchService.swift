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
      
      // 빈 검색어 체크 (공백 제거 후 비어있으면)
      if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        observer.onNext([])
        observer.onCompleted()
        return Disposables.create()
      }
      
      // 현재 observer 저장 (나중에 결과 전달받음)
      self.searchObserver = observer.asObserver()
      
      // 검색 시작
      self.completer.queryFragment = query
      
      return Disposables.create {
        self.completer.cancel()
        self.searchObserver = nil
      }
    }
    .timeout(.seconds(5), scheduler: MainScheduler.instance)
  }
  
  // MARK: - 선택된 위치에 대한 상세 정보 검색
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
  // 자동완성 결과가 도착했을때 호출되는 메서드
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    
    let locations = completer.results.map { completion in
      Location(
        title: completion.title,
        subtitle: completion.subtitle,
        fullAddress: "\(completion.subtitle) \(completion.title)",
        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
      )
    }
    
    searchObserver?.onNext(locations)
    searchObserver?.onCompleted()
    searchObserver = nil
  }
  
  // 검색 중 에러가 발생했을때 호출되는 메서드
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    searchObserver?.onNext([])
    searchObserver?.onCompleted()
    searchObserver = nil
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
