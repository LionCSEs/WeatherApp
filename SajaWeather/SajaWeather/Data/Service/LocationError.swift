//
//  LocationError.swift
//  SajaWeather
//
//  Created by 김우성 on 8/7/25.
//

enum LocationError: Error {
  case authorizationDenied           // 사용자가 권한을 명시적으로 거부
  case authorizationRestricted       // 시스템 정책에 의해 제한됨 (예: 자녀 보호)
  case locationServicesDisabled      // 전체 위치 서비스 꺼짐
  case unableToFetchLocation         // 위치 가져오기에 실패
  case timeout                       // 위치 응답이 너무 늦음
  case unknown                       // 알 수 없는 오류
  
  var localizedDescription: String {
    switch self {
    case .authorizationDenied:
      return "위치 권한이 거부되었습니다."
    case .authorizationRestricted:
      return "위치 권한이 제한되어 있습니다."
    case .locationServicesDisabled:
      return "위치 서비스가 꺼져 있습니다. 설정에서 켜주세요."
    case .unableToFetchLocation:
      return "위치를 가져오지 못했습니다."
    case .timeout:
      return "위치 요청이 너무 오래 걸렸습니다."
    case .unknown:
      return "알 수 없는 위치 오류가 발생했습니다."
    }
  }
}
