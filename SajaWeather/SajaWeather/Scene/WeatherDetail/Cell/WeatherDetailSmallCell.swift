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
      VStack(alignment: .leading) {
        Text(title)
          .font(.system(size: 12))
        Text(value)
          .font(.system(size: 18, weight: .bold))
      }
    }
  }
}

#Preview {
  WeatherDetailSmallCell(icon: "humidity.fill", title: "습도", value: "79%")
}
