//
//  DateFormatter+.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation
import Then

extension DateFormatter {
  
  /// 시간별 예보용 포맷터
  /// 형식: 12AM, 1PM, 11PM
  private static let hourlyFormatter = DateFormatter().then {
    $0.dateFormat = "ha"
    $0.locale = Locale(identifier: "en_US")
  }
  
  /// 일출/일몰 시간용 포맷터
  /// 형식: 6:30AM, 7:45PM
  private static let timeFormatter = DateFormatter().then {
    $0.dateFormat = "h:mma"
    $0.locale = Locale(identifier: "en_US")
  }
  
  /// 일별 예보용 포맷터
  /// 형식: 8월 8일 금요일, 8월 9일 토요일
  private static let dayFormatter = DateFormatter().then {
    $0.dateFormat = "MM월 dd일 EEEE"
    $0.locale = Locale(identifier: "ko_KR")
  }
  
  private static let calendar = Calendar.current
  
  /// Unix timestamp를 시간별 예보 형식으로 변환
  /// - Parameter timeInterval: Unix timestamp
  /// - Returns: "12AM", "1PM" 형식의 문자열
  /// - Example: `DateFormatter.formatHour(1691456400)` -> "3PM"
  static func formatHour(_ timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    return hourlyFormatter.string(from: date)
  }
  
  /// Unix timestamp를 일출/일몰 시간 형식으로 변환
  /// - Parameter timeInterval: Unix timestamp
  /// - Returns: "6:30AM" 형식의 문자열
  /// - Example: `DateFormatter.formatTime(1691456400)` -> "6:30AM"
  static func formatTime(_ timeInterval: TimeInterval) -> Date {
    let date = Date(timeIntervalSince1970: timeInterval)
    return date //timeFormatter.string(from: date)
  }
  
  /// Unix timestamp를 일별 예보 형식으로 변환
  /// - Parameter timeInterval: Unix timestamp
  /// - Returns: 당일이면 "오늘", 그 외는 "8월 8일 금요일" 형식
  /// - Example: `DateFormatter.formatDay(1691456400)` -> "오늘" 또는 "8월 8일 화요일"
  static func formatDay(_ timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    if calendar.isDateInToday(date) {
      return "오늘"
    }
    return dayFormatter.string(from: date)
  }
}
