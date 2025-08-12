//
//  WeatherSunCycleRow.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import SwiftUI

struct SunCycleCell: View {
  let icon: String
  let title: String
  let date: Date
  
  private var parts: (time: String, ampm: String) {
    return DateFormatter.formatTimeAndAmPm(date.timeIntervalSince1970)
  }
  
  var body: some View {
    HStack {
      Image(systemName: icon)
        .resizable()
        .frame(width: 20, height: 20)
        .foregroundStyle(.white)
      VStack(alignment: .leading, spacing: 5) {
        Text(title)
          .font(.system(size: 12))
          .foregroundStyle(.white)
        HStack(alignment: .bottom, spacing: 0) {
          Text(parts.time)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
          Text(parts.ampm)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
        }
      }
    }
  }
}

struct WeatherSunCycleRow: View {
  let sunrise: Date
  let sunset: Date

  var body: some View {
    HStack(spacing: 40) {
      SunCycleCell(icon: "sunrise.fill", title: "일출", date: sunrise)
      SunCycleCell(icon: "sunset.fill",  title: "일몰", date: sunset)
    }
  }
}

#Preview {
  WeatherSunCycleRow(sunrise: Date(), sunset: Date().addingTimeInterval(60*60*12+375))
    .padding()
}
