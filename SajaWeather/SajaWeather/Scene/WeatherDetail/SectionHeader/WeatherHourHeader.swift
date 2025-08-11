//
//  WeatherHourHeader.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI

struct WeatherHourHeader: View {
  var body: some View {
    HStack {
      Image(systemName: "clock")
        .resizable()
        .frame(width: 13.5, height: 13.5)
      Text("시간별 예보")
        .font(.system(size: 12))
      Spacer()
    }
  }
}

#Preview {
  WeatherHourHeader()
}
