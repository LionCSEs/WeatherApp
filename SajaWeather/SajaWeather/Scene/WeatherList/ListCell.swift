//
//  ListCell.swift
//  SajaWeather
//
//  Created by estelle on 8/11/25.
//

import UIKit
import SnapKit
import Then

class ListCell: UICollectionViewCell {
  static let identifier = "ListCell"
  
  // 배경 이미지 뷰
  private let backgroundImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.clipsToBounds = true
    $0.image = UIImage(named: "testImg")
  }
  
  // 좌상단 현재 온도
  private let currentTempLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 45, weight: .bold)
    $0.textColor = .white
    $0.text = "25"
  }
  
  // 좌하단 정보들
  private lazy var locationInfoStackView = UIStackView(arrangedSubviews: [locationLabel, detailTempLabel]).then {
    $0.axis = .vertical
    $0.spacing = 4
    $0.alignment = .leading
  }
  
  private let locationLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.textColor = .white
    $0.text = "Seoul"
  }
  
  private let detailTempLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .medium)
    $0.textColor = .white
    $0.text = "0°C / 10°C"
  }
  
  // 우상단 날씨 아이콘
  private let weatherIconImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(systemName: "sun.max.fill")
  }
  
  // 우하단 날씨 설명
  private let weatherDescriptionLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .semibold)
    $0.textColor = .white
    $0.text = "bb"
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
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 10)
    layer.shadowOpacity = 0.25
    layer.shadowRadius = 8
    
    [backgroundImageView, currentTempLabel, locationInfoStackView, weatherIconImageView, weatherDescriptionLabel].forEach {
      contentView.addSubview($0)
    }
    
    backgroundImageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    currentTempLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(20)
    }
    
    locationInfoStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(10)
      $0.leading.equalToSuperview().inset(20)
    }
    
    weatherIconImageView.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(20)
      $0.width.height.equalTo(100)
    }
    
    weatherDescriptionLabel.snp.makeConstraints {
      $0.bottom.equalToSuperview().inset(10)
      $0.trailing.equalToSuperview().inset(20)
    }
  }
  
  func configure(with data: CurrentWeather) {
    //backgroundImageView.image = UIImage(named: data)
    currentTempLabel.text = "\(data.temperature)°c"
    locationLabel.text = data.address.fullAddress
    detailTempLabel.text = "↑\(data.maxTemp)°↓\(data.minTemp)° · 체감 온도 \(data.feelsLikeTemp)°"
    weatherIconImageView.image = UIImage(systemName: "sun.max.fill")
    weatherDescriptionLabel.text = data.description
  }
}
