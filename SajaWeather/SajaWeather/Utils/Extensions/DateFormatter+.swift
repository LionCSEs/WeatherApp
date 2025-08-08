//
//  DateFormatter+.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation

extension DateFormatter {
  /// 12AM, 1PM
  static func hourlyFormatter(_ timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    let formatter = DateFormatter()
    formatter.dateFormat = "ha"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
  }
  
  /// 17:29
  static func timeFormatter(_ timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    let formatter = DateFormatter()
    formatter.dateFormat = "h:MM"
    formatter.locale = Locale(identifier: "en_US")
    return formatter.string(from: date)
  }
  
  /// 당일이면 "오늘", 나머지는 "8월 8일 금요일" 반환
  static func dayFormatter(_ timeInterval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timeInterval)
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
      return "오늘"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MM월 dd일 EEEE"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
  }
}
