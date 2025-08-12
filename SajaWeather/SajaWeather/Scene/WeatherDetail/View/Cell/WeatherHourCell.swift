//
//  WeatherHourCell.swift
//  SajaWeather
//
//  Created by 김우성 on 8/8/25.
//

import SwiftUI

struct WeatherHourCell: View {
  let date: Date
  let icon: Int // id or cod
  let temp: Int
  let humidity: Int
  let isDayTime: Bool
  
  var body: some View {
    VStack(spacing: 6) {
      Text(DateFormatter.hourString(from: date))
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(.white)
      
      Image(weatherIcon(for: icon, isDayTime: isDayTime))
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 45, height: 45)
        .padding(-6) // 이미지 자체 공백 제거용
      
      Text("\(humidity)%")
        .font(.system(size: 10, weight: .medium))
        .foregroundStyle(.skyBlue)
      
      Text("\(temp)°")
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(.white)
    }
    .padding(10)
    .background(Color(.gray).opacity(0.25))
    .overlay(
      RoundedRectangle(cornerRadius: 50)
        .stroke(Color.white.opacity(0.20), lineWidth: 1)
    )
    .cornerRadius(50)
  }
}

#Preview {
  WeatherHourCell(date: Date(), icon: 300, temp: 26, humidity: 10, isDayTime: true)
}
