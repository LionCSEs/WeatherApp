//
//  DateFormatter+.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation
import Then

extension DateFormatter {
  private static let calendar = Calendar.current
  
  /// 시간별 예보용 포맷터
  /// 형식: 12AM, 1PM, 11PM
  private static let hourlyFormatter = DateFormatter().then {
    $0.dateFormat = "ha"
    $0.locale = Locale(identifier: "en_US")
  }
  
  /// 일출/일몰 시간용 포맷터 ->  아래 두개로 나눠지기 때문에 없애도 됨
  /// 형식: 6:30AM, 7:45PM
  private static let timeFormatter = DateFormatter().then {
    $0.dateFormat = "h:mma"
    $0.locale = Locale(identifier: "en_US")
  }
  
  private static let timeOnlyFormatter = DateFormatter().then {
    $0.dateFormat = "h:mm" // 시간 부분만 포맷
    $0.locale = Locale(identifier: "en_US")
  }
  
  private static let ampmFormatter = DateFormatter().then {
    $0.dateFormat = "a" // AM/PM 부분만 포맷
    $0.locale = Locale(identifier: "en_US")
  }
  
  /// 일별 예보용 포맷터
  /// 형식: 8월 8일 금요일, 8월 9일 토요일
  private static let dayKoFormatter = DateFormatter().then {
    $0.dateFormat = "MM월 dd일 EEEE"
    $0.locale = Locale(identifier: "ko_KR")
  }
  
  // MARK: - Display helpers
  static func hourString(from date: Date, timeZone: TimeZone) -> String {
    hourlyFormatter.timeZone = timeZone
    return hourlyFormatter.string(from: date)
  }
  
  static func dayKoString(from date: Date, timeZone: TimeZone) -> String {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    if cal.isDate(date, equalTo: Date(), toGranularity: .day) { return "오늘" }
    dayKoFormatter.timeZone = timeZone
    return dayKoFormatter.string(from: date)
  }
  
  static func timeParts(from date: Date, timeZone: TimeZone) -> (time: String, ampm: String) {
    timeOnlyFormatter.timeZone = timeZone
    ampmFormatter.timeZone = timeZone
    return (timeOnlyFormatter.string(from: date), ampmFormatter.string(from: date))
  }
  
  // MARK: - Daytime check
  /// 해당 날짜의 일출/일몰 구간 포함 여부
  static func isDayTime(at date: Date, sunrise: Date, sunset: Date) -> Bool {
    return (sunrise ... sunset).contains(date)
  }
  
  // MARK: - Utils
  static func isSameDay(_ a: Date, _ b: Date, timeZone: TimeZone) -> Bool {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar.isDate(a, inSameDayAs: b)
  }
}
