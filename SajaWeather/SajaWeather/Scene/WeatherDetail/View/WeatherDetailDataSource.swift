//
//  WeatherDetailDataSource.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
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
    // Default
    let defaultCell = UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { cell, _, _ in
      cell.backgroundColor = .systemGray5
    }

    // 시간별
    let hourlyCell = UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, item in
        guard case let .hourlyWeather(idx) = item,
              let h = self?.currentWeather?.hourlyForecast[safe: idx],
              let sunrise = self?.currentWeather?.sunrise,
              let sunset = self?.currentWeather?.sunset
        else { return }

        // HourlyForecast 모델을 건드리지 않고, 필요한 데이터를 조합하여 isDayTime을 계산
        let isDayTime = DateFormatter.isDayTime(for: h.hour, sunrise: sunrise, sunset: sunset)

        cell.contentConfiguration = UIHostingConfiguration {
            WeatherHourCell(
                hour: h.hour,
                icon: h.icon,
                temp: h.temperature,
                humidity: h.humidity,
                isDayTime: isDayTime // 계산된 값을 전달
            )
            .background(Color.clear)
        }.margins(.all, 0)
        cell.backgroundColor = .clear
    }

    // 일별
    let dailyCell = UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, item in
      guard case let .dailyWeather(idx) = item, let d = self?.currentWeather?.dailyForecast[safe: idx] else { return }
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherDayCell(date: d.day, humidity: d.humidity, icon: d.icon, maxTemp: d.maxTemp, minTemp: d.minTemp)
          .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = .clear
    }

    // air: 습도/바람/미세먼지
    let airCell = UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, item in
      let cw = self?.currentWeather
      let (icon, title, value): (String, String, String) = {
        switch item {
        case .humidity:  return ("humidity.fill", "습도", "\(cw?.humidity ?? 0)%")
        case .windSpeed: return ("wind", "바람", "\(cw?.windSpeed ?? 0)m/s")
        case .fineDust:  return ("aqi.medium", "미세먼지", cw?.airQuality.description ?? "-")
        default:         return ("questionmark.circle", "정보 없음", "-")
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

    // 일출/일몰
    let sunCycleCell = UICollectionView.CellRegistration<UICollectionViewCell, WeatherDetailItem> { [weak self] cell, _, _ in
      let cw = self?.currentWeather
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherSunCycleRow(sunrise: cw?.sunrise ?? Date(), sunset: cw?.sunset ?? Date())
          .background(Color.clear)
      }.margins(.all, 0)
      cell.backgroundColor = .clear
    }

    // Header
    let headerRegistration = UICollectionView.SupplementaryRegistration<WeatherDetailHeaderView>(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { view, _, indexPath in
      // 섹션 0: 시간별, 1: 일별 (레이아웃도 이 두 섹션만 헤더 존재)
      switch indexPath.section {
      case 0:
        view.icon = "clock"
        view.title = "시간별 예보"
        view.additional = nil
      case 1:
        view.icon = "calendar"
        view.title = "일별 예보"
        view.additional = "최고  ∙  최저"
      default:
        view.icon = ""
        view.title = ""
        view.additional = nil
      }
    }

    // DataSource
    let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .hourlyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: hourlyCell, for: indexPath, item: item)
      case .dailyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: dailyCell, for: indexPath, item: item)
      case .humidity, .windSpeed, .fineDust:
        return collectionView.dequeueConfiguredReusableCell(using: airCell, for: indexPath, item: item)
      case .sunCycle:
        return collectionView.dequeueConfiguredReusableCell(using: sunCycleCell, for: indexPath, item: item)
      }
    }

    // Header 공급자
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - Helpers
private extension Collection {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
