//
//  WeatherSunCycleRow.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import SwiftUI

struct WeatherSunCycleRow: View {
  let sunrise: String
  let sunset: String

  var body: some View {
    HStack(spacing: 40) {
      WeatherDetailSmallCell(icon: "sunrise.fill", title: "일출", value: sunrise)
      WeatherDetailSmallCell(icon: "sunset.fill",  title: "일몰", value: sunset)
    }
    .frame(maxWidth: .infinity, alignment: .center)
  }
}

#Preview {
  WeatherSunCycleRow(sunrise: "5:40AM", sunset: "7:32PM")
    .padding()
}
