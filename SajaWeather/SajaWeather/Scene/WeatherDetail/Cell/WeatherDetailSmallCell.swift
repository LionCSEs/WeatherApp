//
//  WeatherDetailSmallCell.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI

struct WeatherDetailSmallCell: View {
  let icon: String
  let title: String
  let value: String
  
  var body: some View {
    HStack {
      Image(systemName: icon)
        .resizable()
        .frame(width: 20, height: 20)
      VStack(alignment: .leading, spacing: 5) {
        Text(title)
          .font(.system(size: 12))
        Text(value)
          .font(.system(size: 18, weight: .bold))
      }
    }
  }
}

// 습도, 바람, 미세먼지, 일출, 일몰 용
#Preview {
  HStack(spacing: 40) {
    WeatherDetailSmallCell(icon: "humidity.fill", title: "습도", value: "79%")
    WeatherDetailSmallCell(icon: "wind", title: "바람", value: "4m/s")
    WeatherDetailSmallCell(icon: "air.purifier.fill", title: "미세먼지", value: "좋음")
  }
  HStack(spacing: 40) {
    WeatherDetailSmallCell(icon: "sunrise.fill", title: "일출", value: "5:40AM")
    WeatherDetailSmallCell(icon: "sunset", title: "일몰", value: "7:32PM")
  }
}
