//
//  WeatherDetailVC.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import SwiftUI
import CoreLocation

// 데모용 목업
private let currentWeather = CurrentWeather(
  address: Location(
    title: "사직동",
    subtitle: "서울특별시 종로구",
    fullAddress: "서울특별시 종로구 사직동",
    coordinate: CLLocationCoordinate2D(latitude: 33.5577, longitude: 126.8112)
  ),
  temperature: 25,
  maxTemp: 31,
  minTemp: 24,
  feelsLikeTemp: 26,
  description: "실 비",
  icon: 500,
  hourlyForecast: [
    .init(hour: "지금", icon: 200, temperature: 32, humidity: 74),
    .init(hour: "7AM", icon: 200, temperature: 32, humidity: 72),
    .init(hour: "8AM", icon: 200, temperature: 31, humidity: 70),
    .init(hour: "9AM", icon: 200, temperature: 31, humidity: 68),
    .init(hour: "10AM", icon: 200, temperature: 30, humidity: 67),
    .init(hour: "11AM", icon: 200, temperature: 30, humidity: 65),
    .init(hour: "12PM", icon: 200, temperature: 29, humidity: 64),
    .init(hour: "1PM", icon: 200, temperature: 28, humidity: 66),
    .init(hour: "2PM", icon: 200, temperature: 27, humidity: 70),
    .init(hour: "3PM", icon: 200, temperature: 26, humidity: 73)
  ],
  dailyForecast: [
    .init(day: "오늘", humidity: 10, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 12일 화요일", humidity: 10, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 13일 수요일", humidity: 13, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 14일 목요일", humidity: 12, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 15일 금요일", humidity: 15, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 16일 토요일", humidity: 17, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 17일 일요일", humidity: 40, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 18일 월요일", humidity: 46, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 19일 화요일", humidity: 33, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 20일 수요일", humidity: 21, icon: 701, maxTemp: 31, minTemp: 27),
    .init(day: "8월 21일 목요일", humidity: 12, icon: 701, maxTemp: 31, minTemp: 27)
  ],
  humidity: 89,
  windSpeed: 2,
  airQuality: .good,
  sunrise: "5:40AM",
  sunset: "7:32PM"
)

class WeatherDetailVC: UIViewController, UICollectionViewDelegate {
  private let tempLabel = UILabel().then {
    $0.text = "\(currentWeather.temperature)ºc"
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 45, weight: .bold)
    $0.textAlignment = .center
  }
  
  private let tempDetailLabel = UILabel().then {
    $0.text = "↑\(currentWeather.maxTemp)º ∙ ↓\(currentWeather.minTemp)º\n체감 온도 \(currentWeather.feelsLikeTemp)º"
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 16)
    $0.textAlignment = .center
    $0.numberOfLines = 2
  }
  
  private let temperatureView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 8
  }
  
  private let weatherIconView = UIImageView().then {
    $0.image = UIImage(named: "Day Clear")
    $0.contentMode = .scaleAspectFit
  }
  
  private let lionIconView = UIImageView().then {
    $0.image = UIImage(named: "Lion Sun")
    $0.contentMode = .scaleAspectFit
  }
  
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.backgroundColor = .clear
    $0.contentInset = UIEdgeInsets(top: 520, left: 0, bottom: 0, right: 0)
    $0.clipsToBounds = true
  }
  private lazy var dataSource = makeDataSource(collectionView)
  
  private let disposeBag = DisposeBag()
  
  private var scrollAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    snapshot.appendSections([.hourly, .daily, .air, .sunCycle]) // .map 제거
    
    snapshot.appendItems((0..<currentWeather.hourlyForecast.count).map { .hourlyWeather($0) }, toSection: .hourly)
    snapshot.appendItems((0..<currentWeather.dailyForecast.count).map { .dailyWeather($0) }, toSection: .daily)
    snapshot.appendItems([.humidity, .windSpeed, .fineDust], toSection: .air)
    snapshot.appendItems([.sunCycle], toSection: .sunCycle)
//    snapshot.appendItems([.map], toSection: .map)
    
    dataSource.apply(snapshot)
    registerObservables()
  }
  
  private func configureUI() {
    view.backgroundColor = .cloudyAndRainyDayTop
    
    var defaultConstraints: [Constraint] = []
    var scrollConstraints: [Constraint] = []
    
    // 온도
    view.addSubview(temperatureView)
    temperatureView.addArrangedSubview(tempLabel)
    temperatureView.addArrangedSubview(tempDetailLabel)
    temperatureView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
      $0.size.equalTo(105)
    }
    defaultConstraints += temperatureView.snp.prepareConstraints {
      $0.centerX.equalToSuperview().constraint.isActive = true
    }
    scrollConstraints += temperatureView.snp.prepareConstraints {
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(40)
    }
    
    // 날씨 아이콘
    view.addSubview(weatherIconView)
    weatherIconView.snp.makeConstraints {
      $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.size.equalTo(133)
    }
    defaultConstraints += weatherIconView.snp.prepareConstraints {
      $0.top.equalTo(temperatureView.snp.bottom).offset(20).constraint.isActive = true
    }
    scrollConstraints += weatherIconView.snp.prepareConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
    
    // 사자
    view.addSubview(lionIconView)
    lionIconView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(248)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.width.equalTo(256)
      $0.height.equalTo(256)
    }
    
    // 컬렉션뷰
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(20)
    }
    
    scrollAnimator.addAnimations { [weak self] in
      for constraint in defaultConstraints { constraint.isActive = false }
      for constraint in scrollConstraints { constraint.isActive = true }
      self?.lionIconView.alpha = 0
      self?.view.layoutIfNeeded()
    }
  }
  
  func registerObservables() {
    rx.viewDidAppear
      .withUnretained(scrollAnimator)
      .take(1)
      .bind { animator, _ in
        animator.pauseAnimation()
      }
      .disposed(by: disposeBag)
    
    rx.deallocating
      .withUnretained(scrollAnimator)
      .bind { animator, _ in
      }
      .disposed(by: disposeBag)
    
    collectionView.rx.didScroll
      .skip(until: rx.viewDidAppear)
      .withUnretained(collectionView)
      .map { collectionView, _ in
        collectionView.contentOffset.y + collectionView.adjustedContentInset.top
      }
      .distinctUntilChanged()
      .bind { [weak self] offset in
        guard let self, scrollAnimator.state == .active else {
          return
        }
        let threshold: CGFloat = 320
        scrollAnimator.fractionComplete = min(1, offset / threshold)
        let transform = if offset > threshold {
          CGAffineTransform(translationX: 0, y: -(offset - threshold))
        } else {
          CGAffineTransform.identity
        }
        temperatureView.transform = transform
        weatherIconView.transform = transform
      }
      .disposed(by: disposeBag)
  }
}

extension WeatherDetailVC {
  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
      guard let self, let section = dataSource.sectionIdentifier(for: sectionIndex) else { return nil }
      let contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45)),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "weatherDetail-background")
      backgroundItem.contentInsets = contentInsets
      
      switch section {
      case .hourly:
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .absolute(50), heightDimension: .fractionalHeight(1))
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .absolute(50), heightDimension: .absolute(133)),
          subitems: [item]
        )
        
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = .init(top: 0, leading: 15, bottom: 20, trailing: 15)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.boundarySupplementaryItems = [header]
        sectionLayout.interGroupSpacing = 15
        sectionLayout.decorationItems = [backgroundItem]
        return sectionLayout
        
      case .daily:
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(38))
        )
        let group = NSCollectionLayoutGroup.vertical(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(38)),
          subitems: [item]
        )
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = .init(top: 0, leading: 15, bottom: 20, trailing: 15)
        sectionLayout.interGroupSpacing = 5
        sectionLayout.boundarySupplementaryItems = [header]
        sectionLayout.decorationItems = [backgroundItem]
        return sectionLayout
        
      case .air:
        let spacing: CGFloat = 20
        let containerWidth = (environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing)
        let itemWidth = (containerWidth - spacing * 2) / 3
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .absolute(itemWidth), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(68)),
          repeatingSubitem: item, count: 3
        ).then { $0.interItemSpacing = .fixed(spacing) }
        return NSCollectionLayoutSection(group: group).then {
          $0.contentInsets = contentInsets
        }
        
      case .sunCycle:
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(68)),
          subitems: [item]
        )
        return NSCollectionLayoutSection(group: group).then {
          $0.contentInsets = contentInsets
          $0.decorationItems = [backgroundItem]
        }
        
      case .map:
        let item = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
          )
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(253)
          ),
          subitems: [item]
        )
        return NSCollectionLayoutSection(group: group).then {
          $0.contentInsets = contentInsets
        }
      }
    }
    
    layout.register(WeatherBackgroundView.self, forDecorationViewOfKind: "weatherDetail-background")

    return layout
  }
  
  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Item> {
    
    let defaultCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, _, _ in
      cell.backgroundColor = .systemGray5
    }
    
    // 시간별 셀
    let hourlyCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { [weak self] cell, indexPath, item in
      guard let self else { return }
      guard case let .hourlyWeather(idx) = item, idx < currentWeather.hourlyForecast.count else { return }
      let h = currentWeather.hourlyForecast[idx]
      
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherHourCell(
          hour: h.hour,
          icon: String(h.icon),
          temp: h.temperature,
          humidity: h.humidity
        )
        .background(Color.clear)
      }
      .margins(.all, 0)
      cell.backgroundColor = .clear
    }
    
    // 일별 셀
    let dailyCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { [weak self] cell, indexPath, item in
      guard let self else { return }
      guard case let .dailyWeather(idx) = item, idx < currentWeather.dailyForecast.count else { return }
      let d = currentWeather.dailyForecast[idx]
      
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherDayCell(
          date: d.day,
          humidity: d.humidity,
          icon: "\(d.icon)d",
          maxTemp: d.maxTemp,
          minTemp: d.minTemp
        )
        .background(Color.clear)
      }
      .margins(.all, 0)
      cell.backgroundColor = .clear
    }
    
    // air: 습도/바람/미세먼지
    let airCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, _, item in
      let (icon, title, value): (String, String, String) = {
        switch item {
        case .humidity:  return ("humidity.fill", "습도", "\(currentWeather.humidity)%")
        case .windSpeed: return ("wind", "바람", "\(currentWeather.windSpeed)m/s")
        case .fineDust:  return ("aqi.medium", "미세먼지", currentWeather.airQuality.description)
        default:         return ("questionmark.circle", "정보 없음", "-")
        }
      }()
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherDetailSmallCell(icon: icon, title: title, value: value)
          .background(Color.clear)
      }
      .margins(.all, 0)
      cell.backgroundColor = UIColor(.gray).withAlphaComponent(0.25)
      cell.layer.cornerRadius = 15
      cell.layer.masksToBounds = true
    }
    
    // sunCycle: 일출/일몰 한 줄
    let sunCycleCell = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, _, _ in
      cell.contentConfiguration = UIHostingConfiguration {
        WeatherSunCycleRow(sunrise: currentWeather.sunrise, sunset: currentWeather.sunset)
          .background(Color.clear)
      }
      .margins(.all, 0)
      cell.backgroundColor = .clear
    }
    
    let supplementaryViewRegistration = UICollectionView.SupplementaryRegistration<WeatherDetailHeaderView>(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] view, _, indexPath in
      guard let section = self?.dataSource.sectionIdentifier(for: indexPath.section) else {
        return
      }
      
      switch section {
      case .hourly:
        view.title = "시간별 예보"
        view.icon = "clock"
      case .daily:
        view.title = "일별 예보"
        view.icon = "calendar"
        view.additional = "최고  ∙  최저"
      default:
        break
      }
    }
    
    let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
      switch item {
      case .hourlyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: hourlyCell, for: indexPath, item: item)
      case .dailyWeather:
        return collectionView.dequeueConfiguredReusableCell(using: dailyCell, for: indexPath, item: item)
      case .humidity, .windSpeed, .fineDust:
        return collectionView.dequeueConfiguredReusableCell(using: airCell, for: indexPath, item: item)
      case .sunCycle:
        return collectionView.dequeueConfiguredReusableCell(using: sunCycleCell, for: indexPath, item: item)
      default:
        return collectionView.dequeueConfiguredReusableCell(using: defaultCell, for: indexPath, item: item)
      }
    }
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: supplementaryViewRegistration, for: indexPath)
    }
    return dataSource
  }
}

extension WeatherDetailVC {
  enum Section {
    case hourly
    case daily
    case air
    case sunCycle
    case map
  }
  
  enum Item: Hashable {
    case hourlyWeather(Int)
    case dailyWeather(Int)
    case humidity
    case windSpeed
    case fineDust
    case sunCycle
    case map
  }
}

@available(iOS 17.0, *)
#Preview {
  WeatherDetailVC()
}
