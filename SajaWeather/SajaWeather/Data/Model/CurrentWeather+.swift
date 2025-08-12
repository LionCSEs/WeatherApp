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
    
    // 현재 일출/일몰
    self.sunrise = Date(timeIntervalSince1970: TimeInterval(currentWeather.sys.sunrise))
    self.sunset  = Date(timeIntervalSince1970: TimeInterval(currentWeather.sys.sunset))
    
    // 대기질
    let aqiValue = airQuality.list.first?.main.aqi ?? 1
    self.airQuality = AirQuality(rawValue: aqiValue) ?? .good
    
    // 시간별
    self.hourlyForecast = hourlyForecast.list.map { item in
      HourlyForecast(
        date: Date(timeIntervalSince1970: TimeInterval(item.dt)),
        icon: item.weather.first?.id ?? 800,
        temperature: Int(item.main.temp.rounded()),
        humidity: item.main.humidity
      )
    }
    
    // 일별
    self.dailyForecast = dailyForecast.list.map { item in
      DailyForecast(
        date: Date(timeIntervalSince1970: TimeInterval(item.dt)),
        humidity: item.humidity,
        icon: item.weather.first?.id ?? 800,
        maxTemp: Int(item.temp.max.rounded()),
        minTemp: Int(item.temp.min.rounded()),
        sunrise: Date(timeIntervalSince1970: TimeInterval(item.sunrise)),
        sunset:  Date(timeIntervalSince1970: TimeInterval(item.sunset))
      )
    }
  }
}

extension CurrentWeather {
  var backgroundStyle: GradientStyle {
    let isDayTime = (sunrise...sunset).contains(Date())
    switch icon {
    case 200...232:
      return isDayTime ? .thunderDay : .thunderNight
    case 300...321, 500...531:
      return isDayTime ? .rainyDay : .rainyNight
    case 600...622:
      return isDayTime ? .snowyDay : .snowyNight
    case 700...781, 801...804:
      return isDayTime ? .cloudyDay : .cloudyNight
    case 800:
      return isDayTime ? .clearDay : .clearNight
    default:
      return .unknown
    }
  }
  
  /// 현재 시각 기준 주/야
  var isDayNow: Bool {
    (sunrise ... sunset).contains(Date())
  }
}
