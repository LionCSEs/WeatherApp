//
//  UserDefaultsService.swift
//  SajaWeather
//
//  Created by estelle on 8/7/25.
//

import Foundation

enum UserDefaultsKey {
  static let recentSearchHistory = "recentSearchHistory"
  static let savedLocation = "savedLocation"
}

class UserDefaultsService {
  static let shared = UserDefaultsService()
  private let defaults = UserDefaults.standard
  
  private init() {}
  
  // MARK: - 최근 검색어 관리
  
  func loadRecentSearchHistory() -> [String] {
    return defaults.stringArray(forKey: UserDefaultsKey.recentSearchHistory) ?? []
  }
  
  func addRecentSearchHistory(_ keyword: String) {
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
  
  // MARK: - 저장된 위치 관리
  
  func loadSavedLocation() -> [SavedLocation] {
    guard let data = defaults.data(forKey: UserDefaultsKey.savedLocation),
          let locationData = try? JSONDecoder().decode([SavedLocation].self, from: data) else {
      return []
    }
    return locationData
  }
  
  func addSavedLocation(_ location: SavedLocation) {
    var locations = loadSavedLocation()
    if !locations.contains(where: { $0.name == location.name }) {
      locations.append(location)
      saveSavedLocation(locations)
    }
  }
  
  func removeSavedLocation(name: String) {
    var locations = loadSavedLocation()
    locations.removeAll { $0.name == name }
    saveSavedLocation(locations)
  }
  
  func saveSavedLocation(_ locations: [SavedLocation]) {
    if let data = try? JSONEncoder().encode(locations) {
      defaults.set(data, forKey: UserDefaultsKey.savedLocation)
    }
  }
}
