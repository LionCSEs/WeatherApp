//
//  Location.swift
//  SajaWeather
//
//  Created by Milou on 8/6/25.
//

import Foundation
import CoreLocation

struct Location {
  let fullAddress: String     // 나중에 MKLocalSearch로
  let displayAddress: String       // 나중에 MKLocalSearch로
  let coordinate: CLLocationCoordinate2D
}
