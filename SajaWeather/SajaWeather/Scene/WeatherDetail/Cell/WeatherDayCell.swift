//
//  WeatherDayCell.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI

struct WeatherDayCell: View {
  let date: String
  let humidity: Int
  let icon: String // id or cod
  let maxTemp: Int
  let minTemp: Int
  
  var body: some View {
    HStack {
      Text(date)
        .font(.system(size: 14))
        .foregroundStyle(.white)
      Spacer()
      Text("\(humidity)%")
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.skyBlue)
        .padding(.trailing, 5)
      Image(icon)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 33, height: 33)
        .padding(-5) // 이미지 자체 공백 제거용
        .padding(.trailing, 20)
      Text("\(maxTemp)°")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
      Text("\(minTemp)°")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(.white)
        .opacity(0.5)
    }
  }
}

#Preview {
  WeatherDayCell(date: "8월 11일 월요일", humidity: 10, icon: "200", maxTemp: 31, minTemp: 27)
}
