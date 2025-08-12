//
//  WeatherDetailDataSource.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import UIKit
import SwiftUI

// MARK: - Section/Item
enum WeatherDetailSection {
  case hourly
  case daily
  case air
  case sunCycle
}

enum WeatherDetailItem: Hashable {
  case hourlyWeather(Int)
  case dailyWeather(Int)
  case humidity
  case windSpeed
  case fineDust
  case sunCycle
}

// MARK: - Provider
final class WeatherDetailDataSourceProvider {
  typealias DataSource = UICollectionViewDiffableDataSource<WeatherDetailSection, WeatherDetailItem>
  
  private(set) var dataSource: DataSource!
  private weak var collectionView: UICollectionView?
  private var currentWeather: CurrentWeather?
  
  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
    self.dataSource = makeDataSource(collectionView)
  }
  
  func applyInitialSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<WeatherDetailSection, WeatherDetailItem>()
    snapshot.appendSections([.hourly, .daily, .air, .sunCycle])
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  func apply(weather: CurrentWeather, animated: Bool) {
    self.currentWeather = weather
    var snapshot = NSDiffableDataSourceSnapshot<WeatherDetailSection, WeatherDetailItem>()
    snapshot.appendSections([.hourly, .daily, .air, .sunCycle])
    
    snapshot.appendItems(
      (0..<weather.hourlyForecast.count).map { .hourlyWeather($0) },
      toSection: .hourly
    )
    snapshot.appendItems(
      (0..<weather.dailyForecast.count).map { .dailyWeather($0) },
      toSection: .daily
    )
    snapshot.appendItems([.humidity, .windSpeed, .fineDust], toSection: .air)
    snapshot.appendItems([.sunCycle], toSection: .sunCycle)
    
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  // MARK: - DataSource & Registrations
  private func makeDataSource(_ collectionView: UICollectionView) -> DataSource {
    // 1. 각 셀 등록 객체들 생성
    let hourlyCellRegistration = makeHourlyCellRegistration()
    let dailyCellRegistration = makeDailyCellRegistration()
    let airCellRegistration = makeAirCellRegistration()
    let sunCycleCellRegistration = makeSunCycleCellRegistration()
    let headerRegistration = makeHeaderRegistration()
    
    // 2. 데이터 소스 생성 & 셀 공급자 클로저 설정
    let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .hourlyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: hourlyCellRegistration, for: indexPath, item: item)
      case .dailyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: dailyCellRegistration, for: indexPath, item: item)
      case .humidity, .windSpeed, .fineDust:
        return collectionView.dequeueConfiguredReusableCell(using: airCellRegistration, for: indexPath, item: item)
      case .sunCycle:
        return collectionView.dequeueConfiguredReusableCell(using: sunCycleCellRegistration, for: indexPath, item: item)
      }
    }
    
    // 3. 헤더 공급자 설정
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
    
    return dataSource
  }
  
  // MARK: - Cell Registration Helpers
  
  // 시간별 셀 등록 로직
  private func makeHourlyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> {
    return UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, item in
      guard case let .hourlyWeather(index) = item,
            let currentWeather = self?.currentWeather,
            let hourly = currentWeather.hourlyForecast[safe: index]
      else { return }
      
      let isDayTime = DateFormatter.isDayTime(at: hourly.date, sunrise: currentWeather.sunrise, sunset: currentWeather.sunset)
      
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherHourCell(
          date: hourly.date,
          icon: hourly.icon,
          temp: hourly.temperature,
          humidity: hourly.humidity,
          isDayTime: isDayTime,
          timeZone: currentWeather.timeZone
        )
        .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = .clear
    }
  }
  
  // 일별 셀 등록 로직
  private func makeDailyCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> {
    UICollectionView.CellRegistration { [weak self] cell, _, item in
      guard case let .dailyWeather(idx) = item,
            let currentWeather = self?.currentWeather,
            let daily = currentWeather.dailyForecast[safe: idx] else { return }
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherDayCell(
          date: daily.date,
          humidity: daily.humidity,
          icon: daily.icon,
          maxTemp: daily.maxTemp,
          minTemp: daily.minTemp,
          timeZone: currentWeather.timeZone
        )
        .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = .clear
    }
  }
  
  // 습도/바람/미세먼지 셀 등록 로직
  private func makeAirCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> {
    return UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, item in
      let cw = self?.currentWeather
      let (icon, title, value): (String, String, String) = {
        switch item {
        case .humidity: return ("humidity.fill", "습도", "\(cw?.humidity ?? 0)%")
        case .windSpeed: return ("wind", "바람", "\(cw?.windSpeed ?? 0)m/s")
        case .fineDust: return ("aqi.medium", "미세먼지", cw?.airQuality.description ?? "-")
        default: return ("questionmark.circle", "정보 없음", "-")
        }
      }()
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherDetailSmallCell(icon: icon, title: title, value: value)
          .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = UIColor(.gray).withAlphaComponent(0.25)
      cell.layer.cornerRadius = 15
      cell.layer.masksToBounds = true
    }
  }
  
  // 일출/일몰 셀 등록 로직
  private func makeSunCycleCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> {
    UICollectionView.CellRegistration { [weak self] cell, _, _ in
      guard let currentWeather = self?.currentWeather else { return }
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherSunCycleRow(
          sunrise: currentWeather.sunrise,
          sunset:  currentWeather.sunset,
          timeZone: currentWeather.timeZone
        )
        .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = .clear
    }
  }
  
  // 헤더 등록 로직
  private func makeHeaderRegistration() -> UICollectionView.SupplementaryRegistration<WeatherDetailHeaderView> {
    return UICollectionView.SupplementaryRegistration<WeatherDetailHeaderView>(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { view, _, indexPath in
      switch indexPath.section {
      case 0:
        view.icon = "clock"
        view.title = "시간별 예보"
        view.additional = nil
      case 1:
        view.icon = "calendar"
        view.title = "일별 예보"
        view.additional = "최고 ∙ 최저"
      default:
        view.icon = ""
        view.title = ""
        view.additional = nil
      }
    }
  }
}

// MARK: - Helpers
private extension Collection {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
