//
//  UserDefaultsService.swift
//  SajaWeather
//
//  Created by estelle on 8/7/25.
//

import Foundation

enum UserDefaultsKey {
  static let recentSearchHistory = "recentSearchHistory"
  static let recentSearchLocations = "recentSearchLocations"
  static let savedLocation = "savedLocation"
  static let temperatureUnit = "TemperatureUnit"
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
  
  // MARK: - 최근 검색어 위치 관리
  
  func loadRecentSearchLocations() -> [Location] {
    guard let data = defaults.data(forKey: UserDefaultsKey.recentSearchLocations),
          let locations = try? JSONDecoder().decode([Location].self, from: data) else {
      return []
    }
    return locations
  }
  
  func addRecentSearchLocation(_ location: Location) {
    var locations = loadRecentSearchLocations()
    
    // 중복 제거
    locations.removeAll { existingLocation in
      existingLocation.title == location.title &&
      existingLocation.subtitle == location.subtitle
    }
    
    // 최신 위치를 맨 앞에 추가
    locations.insert(location, at: 0)
    
    // 10개 제한
    if locations.count > 10 {
      locations = Array(locations.prefix(10))
    }
    
    // 저장
    if let data = try? JSONEncoder().encode(locations) {
      defaults.set(data, forKey: UserDefaultsKey.recentSearchLocations)
    }
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
  
  // MARK: - 섭씨/화씨 관리
  
  func loadTemperatureUnit() -> String {
    defaults.string(forKey: UserDefaultsKey.temperatureUnit) ?? TemperatureUnit.celsius.rawValue
  }
  
  func saveTemperatureUnit(_ temp: String) {
    defaults.set(temp, forKey: UserDefaultsKey.temperatureUnit)
  }
}
