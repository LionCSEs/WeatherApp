//
//  GridCell.swift
//  SajaWeather
//
//  Created by estelle on 8/11/25.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import Lottie

class GridCell: UICollectionViewCell {
  
  static let identifier = "GridCell"
  private static let hostReuseID = "HourHostCell"
  
  private var currentWeather: CurrentWeather?
  private var hourlyForecasts: [HourlyForecast] = []
  
  // 임시 데이터 소스
//  private var hourlyForecasts: [HourlyForecast] = [HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5)]
  
  // MARK: - UI Elements
  
//  private let mainWeatherImageView = UIImageView().then {
//    $0.contentMode = .scaleAspectFit
//    $0.image = UIImage(named: "Day Clear")
//  }
  
  private let mainWeatherImageView = LottieAnimationView().then {
    $0.contentMode = .scaleAspectFit
    $0.loopMode = .loop
    $0.play()
  }
  
  private let locationLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .bold)
    $0.textAlignment = .center
    $0.text = "Seoul"
  }
  
  private let currentTempLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 45, weight: .bold)
    $0.text = "25"
  }
  
  private let tempRangeLabel = UILabel().then {
    // 최고/최저 온도 라벨
    $0.backgroundColor = .cloudyAndRainyDayTop
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 14, weight: .semibold)
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.textAlignment = .center
    $0.text = "↑55° ↓55°"
  }
  
  private let feelsLikeLabel = UILabel().then {
    // 체감 온도 라벨
    $0.backgroundColor = .darkGray.withAlphaComponent(0.8)
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 14, weight: .semibold)
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
    $0.textAlignment = .center
    $0.text = "체감 온도 43"
  }
  
  // 최고/최저, 체감온도를 묶을 스택뷰
  private lazy var tempInfoStackView = UIStackView(arrangedSubviews: [tempRangeLabel, feelsLikeLabel]).then {
    $0.axis = .vertical
    $0.spacing = 6
    $0.alignment = .trailing
  }
  
  private lazy var allTempInfoStackView = UIStackView(arrangedSubviews: [currentTempLabel, tempInfoStackView]).then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.alignment = .center
    $0.distribution = .equalSpacing
  }
  
  let layout = UICollectionViewFlowLayout().then {
    $0.scrollDirection = .horizontal
    $0.itemSize = CGSize(width: 70, height: 140)
    $0.minimumLineSpacing = 12
  }
  
  // 시간별 예보를 보여줄 컬렉션뷰
  private lazy var hourlyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
    $0.backgroundColor = .clear
    $0.showsHorizontalScrollIndicator = false
    $0.dataSource = self
    $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: GridCell.hostReuseID)
  }
  
  private let mainStackView = UIStackView().then {
      $0.axis = .vertical
      $0.spacing = 25
      $0.alignment = .center
    }
  
  private let cardBackgroundView = UIView().then {
    $0.backgroundColor = .white.withAlphaComponent(0.6)
    $0.layer.cornerRadius = 30
    $0.clipsToBounds = true
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = CGSize(width: 0, height: 10)
    $0.layer.shadowOpacity = 0.25
    $0.layer.shadowRadius = 8
    $0.layer.masksToBounds = false
  }
  
  // MARK: - Initializer
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupUI() {
    contentView.addSubview(mainWeatherImageView)
    contentView.addSubview(cardBackgroundView)
    
    mainStackView.addArrangedSubview(locationLabel)
    mainStackView.addArrangedSubview(allTempInfoStackView)
    mainStackView.addArrangedSubview(hourlyCollectionView)
    cardBackgroundView.addSubview(mainStackView)
    
    mainWeatherImageView.snp.makeConstraints {
      $0.height.equalTo(180).priority(999) // 이미지 크기에 맞게 조절
      $0.top.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
    
    cardBackgroundView.snp.makeConstraints {
      $0.top.equalTo(mainWeatherImageView.snp.bottom)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    mainStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(70).priority(999)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(30).priority(999)
    }
    
    tempRangeLabel.snp.makeConstraints {
      $0.width.equalTo(110)
      $0.height.equalTo(25).priority(999)
    }
    feelsLikeLabel.snp.makeConstraints {
      $0.width.equalTo(110)
      $0.height.equalTo(25).priority(999)
    }
    
    locationLabel.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview()
    }
    
    allTempInfoStackView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview()
    }
    
    hourlyCollectionView.snp.makeConstraints {
      $0.height.equalTo(140).priority(999)
      $0.horizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }
  
  func configure(with data: CurrentWeather, tempUnit: TemperatureUnit) {
    self.currentWeather = data
    self.hourlyForecasts = data.hourlyForecast
    
    // 상단 요약
    locationLabel.text = data.address.fullAddress
    currentTempLabel.text = "\(data.temperature)°\(tempUnit.symbol)"
    tempRangeLabel.text  = "↑\(data.maxTemp)° ↓\(data.minTemp)°"
    feelsLikeLabel.text  = "체감 온도 \(data.feelsLikeTemp)°"
    
    // 메인 일러스트 (옵션)
//    mainWeatherImageView.image = UIImage(named: topWeatherIllustrationName(for: data.icon, isDayTime: data.isDayNow))
    mainWeatherImageView.animation = LottieAnimation.named(topWeatherIllustrationName(for: data.icon, isDayTime: data.isDayNow))
    mainWeatherImageView.play()
    
    hourlyCollectionView.reloadData()
  }
  
  // MARK: - Helpers
  /// 해당 시(hourDate)와 같은 날의 일출/일몰 우선 사용, 없으면 현재값 fallback
  private func sunBounds(for hourDate: Date) -> (sunrise: Date, sunset: Date) {
    if let cw = currentWeather,
       let match = cw.dailyForecast.first(where: { DateFormatter.isSameDay($0.date, hourDate) }) {
      return (match.sunrise, match.sunset)
    }
    if let cw = currentWeather { return (cw.sunrise, cw.sunset) }
    let now = Date()
    return (now, now)
  }
}

// MARK: - UICollectionViewDataSource

extension GridCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    hourlyForecasts.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.hostReuseID, for: indexPath)

    let hour = hourlyForecasts[indexPath.item]
    let (sr, ss) = sunBounds(for: hour.date)
    let isDay = DateFormatter.isDayTime(at: hour.date, sunrise: sr, sunset: ss)

    // SwiftUI WeatherHourCell 호스팅
    cell.contentConfiguration = UIHostingConfiguration {
      WeatherHourCell(
        date: hour.date,
        icon: hour.icon,
        temp: hour.temperature,
        humidity: hour.humidity,
        isDayTime: isDay
      )
      .background(Color.clear)
    }.margins(.all, 0)

    cell.backgroundColor = .clear
    return cell
  }
}
