//
//  WeatherIconManager.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import Foundation

/// 에셋 구조에 맞춘 베이스 코드 매핑
/// 여러 날씨 코드를 하나의 베이스 이미지로 통합
// swiftlint:disable:next cyclomatic_complexity
private func baseAssetName(for code: Int) -> String {
  switch code {
    // 천둥/번개
  case 200...202: return "200"      // no d/n
  case 210...211: return "210"      // d/n
  case 212, 221:  return "212"      // no d/n
  case 230...232: return "230"      // no d/n
    
    // 이슬비/비
  case 300...302, 310: return "300" // d/n
  case 311:            return "311" // no d/n
  case 312...314:      return "312" // d/n
  case 321:            return "321" // no d/n
    
  case 500...501:      return "500" // d/n
  case 502...503:      return "502" // no d/n
  case 504, 511, 520:  return "504" // d/n
  case 521...522:      return "521" // no d/n
  case 531:            return "531" // no d/n
    
    // 눈
  case 600...601:      return "600" // d/n
  case 602:            return "602" // no d/n
  case 611...612:      return "611" // d/n
  case 613:            return "613" // no d/n
  case 615...616, 620: return "615" // d/n
  case 621...622:      return "621" // no d/n
    
    // 대기 / 토네이도
  case 701...771:      return "701" // d/n
  case 781:            return "781" // no d/n
    
    // 맑음/구름
  case 800:            return "800" // d/n
  case 801...803:      return "801" // d/n
  case 804:            return "804" // no d/n
    
  default:
    return "800"
  }
}

/// d/n 접미사가 **있는** 베이스 코드 목록 (에셋 기준)
private let basesWithDayNight: Set<String> = [
  "210","300","312","500","504","600","611","615","701","800","801"
]

/// 리스트/상세에서 쓰는 숫자 아이콘 이름
func weatherIcon(for iconCode: Int, isDayTime: Bool) -> String {
  let base = baseAssetName(for: iconCode)
  if basesWithDayNight.contains(base) {
    return base + (isDayTime ? "d" : "n")
  } else {
    return base
  }
}

/// 상단 메인 일러스트(좌: 날씨, 우: 사자) 선택
func topWeatherIllustrationName(for code: Int, isDayTime: Bool) -> String {
  switch code {
  case 200...232: return isDayTime ? "Day Storm"  : "Night Storm"
  case 300...321, 500...531: return isDayTime ? "Day Rain"   : "Night Rain"
  case 600...622: return isDayTime ? "Day Snow"   : "Night Snow"
  case 800:       return isDayTime ? "Day Clear"  : "Night Clear"
  case 801...804: return isDayTime ? "Day Clouds" : "Night Clouds"
  case 701...781: return isDayTime ? "Day Clouds" : "Night Clouds" // "Day Wind"   : "Night Wind"
  default:        return isDayTime ? "Day Clear"  : "Night Clear"
  }
}

func topLionIllustrationName(for code: Int, isDayTime: Bool) -> String {
  // 밤에는 자는 사자
  if !isDayTime { return "Lion Sleep" }
  
  switch code {
  case 200...232: return "Lion Thunderstorm"
  case 300...321, 500...531: return "Lion Rain"
  case 600...622: return "Lion Snow"
  case 701...781: return "Lion Wind"
  case 801...804: return "Lion Cloud"
  case 800: return "Lion Sun"
  default:   return "Lion Sun"
  }
}
