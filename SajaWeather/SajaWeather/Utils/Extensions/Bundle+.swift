//
//  Bundle+.swift
//  SajaWeather
//
//  Created by Milou on 8/7/25.
//

import Foundation

extension Bundle {
    var apiKey: String? {
        return infoDictionary?["WEATHER_API_KEY"] as? String
    }
}
