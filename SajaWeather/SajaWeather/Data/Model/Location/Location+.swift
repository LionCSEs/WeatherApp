//
//  Location+.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import Foundation

extension Location: Codable {
  
  enum CodingKeys: String, CodingKey {
    case title, subtitle, fullAddress, latitude, longitude
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    self.subtitle = try container.decode(String.self, forKey: .subtitle)
    self.fullAddress = try container.decode(String.self, forKey: .fullAddress)
    
    let latitude = try container.decode(Double.self, forKey: .latitude)
    let longitude = try container.decode(Double.self, forKey: .longitude)
    coordinate = Coordinate(latitude: latitude, longitude: longitude)
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(title, forKey: .title)
    try container.encode(subtitle, forKey: .subtitle)
    try container.encode(fullAddress, forKey: .fullAddress)
    try container.encode(coordinate.latitude, forKey: .latitude)
    try container.encode(coordinate.longitude, forKey: .longitude)
  }
}

extension Location: Equatable {
  static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.fullAddress == rhs.fullAddress
  }
}
