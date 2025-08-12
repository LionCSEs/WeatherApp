//
//  WeatherDetailBackgroundView.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import UIKit

class WeatherBackgroundView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configure() {
    backgroundColor = UIColor(.gray).withAlphaComponent(0.25) // 원하는 배경색으로 설정
    layer.cornerRadius = 15 // 원하는 코너 반경으로 설정
    layer.masksToBounds = true
  }
}
