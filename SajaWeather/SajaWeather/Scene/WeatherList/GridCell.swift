//
//  GridCell.swift
//  SajaWeather
//
//  Created by estelle on 8/11/25.
//

import UIKit
import SnapKit
import Then

class GridCell: UICollectionViewCell {
  
  static let identifier = "GridCell"
  
  // 임시 데이터 소스
  private var hourlyForecasts: [HourlyForecast] = [HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5), HourlyForecast(hour: "9", icon: 4, temperature: 5, humidity: 5)]
  
  // MARK: - UI Elements
  
  private let mainWeatherImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "sun.max.fill")
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
  
  // 최고/최저, 체감온도를 묶을 스택뷰
  private lazy var tempInfoStackView = UIStackView(arrangedSubviews: [tempRangeLabel, feelsLikeLabel]).then {
    $0.axis = .vertical
    $0.spacing = 6
    $0.alignment = .trailing
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
    $0.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.identifier)
  }
  
  private lazy var mainStackView = UIStackView(arrangedSubviews: [
    locationLabel, allTempInfoStackView, hourlyCollectionView
  ]).then {
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
    
    [mainWeatherImageView, cardBackgroundView].forEach { contentView.addSubview($0) }
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
    locationLabel.text = data.address.fullAddress
    // mainWeatherImageView.image = UIImage(named: data)
    currentTempLabel.text = tempUnit == .celsius ? "\(data.temperature)°C" : "\(data.temperature)°F"
    tempRangeLabel.text = "↑\(data.maxTemp)° ↓\(data.minTemp)°"
    feelsLikeLabel.text = "체감 온도 \(data.feelsLikeTemp)°"
    
    self.hourlyForecasts = data.hourlyForecast
    self.hourlyCollectionView.reloadData()
  }
}

// MARK: - UICollectionViewDataSource

extension GridCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hourlyForecasts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.identifier, for: indexPath) as? HourlyForecastCell else {
      return UICollectionViewCell()
    }
    let data = hourlyForecasts[indexPath.item]
    cell.configure(with: data)
    return cell
  }
}

// 임시 셀
class HourlyForecastCell: UICollectionViewCell {
  static let identifier = "HourlyForecastCell"
  
  private lazy var stackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [timeLabel, iconImageView, precipitationLabel, temperatureLabel])
    sv.axis = .vertical
    sv.spacing = 8
    sv.alignment = .center
    return sv
  }()
  
  private let timeLabel = UILabel()
  private let iconImageView = UIImageView()
  private let precipitationLabel = UILabel()
  private let temperatureLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    contentView.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
    contentView.layer.cornerRadius = 16
    
    timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
    
    iconImageView.contentMode = .scaleAspectFit
    
    precipitationLabel.font = .systemFont(ofSize: 12, weight: .semibold)
    precipitationLabel.textColor = .systemBlue
    
    temperatureLabel.font = .systemFont(ofSize: 18, weight: .regular)
  }
  
  private func setupLayout() {
    contentView.addSubview(stackView)
    iconImageView.snp.makeConstraints {
      $0.width.height.equalTo(30)
    }
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(12)
    }
  }
  
  func configure(with data: HourlyForecast) {
    timeLabel.text = data.hour
    iconImageView.image = UIImage(systemName: "sun.max.fill")
    precipitationLabel.text = "\(data.humidity)%"
    temperatureLabel.text = "\(data.temperature)°"
  }
}

