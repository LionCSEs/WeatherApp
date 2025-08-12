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
  let timeZone: TimeZone
  
  private var parts: (time: String, ampm: String) {
    DateFormatter.timeParts(from: date, timeZone: timeZone)
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
  let timeZone: TimeZone

  var body: some View {
    HStack(spacing: 40) {
      SunCycleCell(icon: "sunrise.fill", title: "일출", date: sunrise, timeZone: timeZone)
      SunCycleCell(icon: "sunset.fill",  title: "일몰", date: sunset, timeZone: timeZone)
    }
  }
}

#Preview {
  WeatherSunCycleRow(sunrise: Date(), sunset: Date().addingTimeInterval(60*60*12+375), timeZone: .current)
    .padding()
}
