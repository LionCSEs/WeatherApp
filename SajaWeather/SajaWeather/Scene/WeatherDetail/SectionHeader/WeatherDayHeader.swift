//
//  WeatherDayHeader.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI

struct WeatherDayHeader: View {
  var body: some View {
    HStack {
      Image(systemName: "calendar")
        .resizable()
        .frame(width: 13.5, height: 13.5)
      Text("일별 예보")
        .font(.system(size: 12))
      Spacer()
      Text("최고  ∙  최저")
        .font(.system(size: 12))
    }
  }
}

#Preview {
  WeatherDayHeader()
}
