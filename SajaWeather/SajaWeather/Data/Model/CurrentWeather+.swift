//
//  CurrentWeather+.swift
//  SajaWeather
//
//  Created by Milou on 8/8/25.
//

import Foundation
import CoreLocation

extension CurrentWeather {
  init(
    currentWeather: CurrentWeatherResponseDTO,
    hourlyForecast: HourlyForecastResponseDTO,
    dailyForecast: DailyForecastResponseDTO,
    airQuality: AirQualityResponseDTO,
    coordinate: CLLocationCoordinate2D // 현재 위치나 저장된 위치
  ) {
    self.address = Location(
      title: currentWeather.name,
      subtitle:currentWeather.name,
      fullAddress: currentWeather.name, // 임시
      coordinate: coordinate
    )
    
    let main = currentWeather.main
    self.temperature = Int(main.temp.rounded())
    self.maxTemp = Int(main.tempMax.rounded())
    self.minTemp = Int(main.tempMin.rounded())
    self.feelsLikeTemp = Int(main.feelsLike.rounded())
    self.humidity = main.humidity
    self.windSpeed = Int(currentWeather.wind.speed.rounded())
    
    let weather = currentWeather.weather.first
    self.description = weather?.description ?? ""
    self.icon = weather?.id ?? 800 // Clear Sky
    
    let sunrise = currentWeather.sys.sunrise
    let sunset = currentWeather.sys.sunset
    self.sunrise = DateFormatter.formatTime(TimeInterval(sunrise))
    self.sunset = DateFormatter.formatTime(TimeInterval(sunset))
    
    let aqiValue = airQuality.list.first?.main.aqi ?? 1
    self.airQuality = AirQuality(rawValue: aqiValue) ?? .good
    
    self.hourlyForecast = hourlyForecast.list.map { item in
      let hour = DateFormatter.formatHour(TimeInterval(item.dt))
      return HourlyForecast(
        hour: hour,
        icon: item.weather.first?.id ?? 800,
        temperature: Int(item.main.temp.rounded()),
        humidity: item.main.humidity
      )
    }
    
    self.dailyForecast = dailyForecast.list.map { item in
      let day = DateFormatter.formatDay(TimeInterval(item.dt))
      return DailyForecast(
        day: day,
        humidity: item.humidity,
        icon: item.weather.first?.id ?? 800,
        maxTemp: Int(item.temp.max.rounded()),
        minTemp: Int(item.temp.min.rounded()))
    }
  }
}
