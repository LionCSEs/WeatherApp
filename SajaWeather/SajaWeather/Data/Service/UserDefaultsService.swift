//
//  UserDefaultsService.swift
//  SajaWeather
//
//  Created by estelle on 8/7/25.
//

import Foundation

enum UserDefaultsKey {
  static let recentSearchHistory = "recentSearchHistory"
}

class UserDefaultsService {
  static let shared = UserDefaultsService()
  private let defaults = UserDefaults.standard
  
  private init() {}
  
  // MARK: - 최근 검색어 관리
  
  func loadRecentSearchHistory() -> [String] {
    return defaults.stringArray(forKey: UserDefaultsKey.recentSearchHistory) ?? []
  }
  
  func adddRecentSearchHistory(_ keyword: String) {
    var history = loadRecentSearchHistory()
    
    history.removeAll { $0 == keyword }   // 중복 제거
    history.insert(keyword, at: 0)        // 최신 검색어순 정렬
    
    if history.count > 10 {               // 개수 제한
      history = Array(history.prefix(10))
    }
    defaults.set(history, forKey: UserDefaultsKey.recentSearchHistory)
  }
  
  func removeAllRecentSearchHistory() {
    defaults.removeObject(forKey: UserDefaultsKey.recentSearchHistory)
  }
}
