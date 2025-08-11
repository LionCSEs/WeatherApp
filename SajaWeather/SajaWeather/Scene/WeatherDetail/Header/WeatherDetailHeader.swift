//
//  WeatherDetailHeader.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI

struct WeatherDetailHeader: View {
  let icon: String
  let title: String
  let description: String?
  
  var body: some View {
    HStack {
      Image(systemName: icon)
        .resizable()
        .frame(width: 13.5, height: 13.5)
      Text(title)
        .font(.system(size: 12))
      Spacer()
      if let description = description {
        Text(description)
          .font(.system(size: 12))
      }
    }
  }
}

#Preview {
  WeatherDetailHeader(icon: "clock", title: "시간별 예보", description: nil)
  WeatherDetailHeader(icon: "calendar", title: "일별 예보", description: "최고  ∙  최저")
}
