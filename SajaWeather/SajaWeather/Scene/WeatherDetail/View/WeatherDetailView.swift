//
//  WeatherDetailView.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import UIKit
import SnapKit
import Then

final class WeatherDetailView: UIView {

  // MARK: - Background (Gradient)
  private let backgroundGradient = GradientView(style: .clearDay)

  // MARK: - UI
  let tempLabel = UILabel().then {
    $0.textColor = .white
    $0.font = .systemFont(ofSize: 45, weight: .bold)
    $0.textAlignment = .center
  }

  let tempDetailLabel = UILabel().then {
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

  let collectionView: UICollectionView = {
    let layout = WeatherDetailLayoutProvider.makeLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.contentInset = UIEdgeInsets(top: 520, left: 0, bottom: 0, right: 0)
    cv.clipsToBounds = true
    cv.showsVerticalScrollIndicator = false
    return cv
  }()

  // MARK: - Constraints & Animator
  private var defaultConstraints: [Constraint] = []
  private var scrollConstraints: [Constraint] = []

  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Setup
  private func setup() {
    // Gradient 뒤에 깔기
    addSubview(backgroundGradient)
    backgroundGradient.snp.makeConstraints { $0.edges.equalToSuperview() }

    addSubview(temperatureView)
    temperatureView.addArrangedSubview(tempLabel)
    temperatureView.addArrangedSubview(tempDetailLabel)
    temperatureView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).inset(30)
      $0.size.equalTo(105)
    }
    defaultConstraints += temperatureView.snp.prepareConstraints {
      $0.centerX.equalToSuperview().constraint.isActive = true
    }
    scrollConstraints += temperatureView.snp.prepareConstraints {
      $0.trailing.equalTo(safeAreaLayoutGuide).inset(40)
    }

    addSubview(weatherIconView)
    weatherIconView.snp.makeConstraints {
      $0.leading.equalTo(safeAreaLayoutGuide).inset(20)
      $0.size.equalTo(133)
    }
    defaultConstraints += weatherIconView.snp.prepareConstraints {
      $0.top.equalTo(temperatureView.snp.bottom).offset(20).constraint.isActive = true
    }
    scrollConstraints += weatherIconView.snp.prepareConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).inset(20)
    }

    addSubview(lionIconView)
    lionIconView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide).inset(248)
      $0.trailing.equalTo(safeAreaLayoutGuide).inset(20)
      $0.width.height.equalTo(256)
    }

    addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }

  // Decoration 등록(배경 뷰)
  func registerDecoration() {
    if let layout = collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout {
      layout.register(WeatherBackgroundView.self, forDecorationViewOfKind: "weatherDetail-background")
    }
  }

  // 스크롤 애니메이터 구성: 제약 전환 + 사자 투명도
  func makeScrollAnimator() -> UIViewPropertyAnimator {
    let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
    animator.addAnimations { [weak self] in
      guard let self else { return }
      for c in self.defaultConstraints { c.isActive = false }
      for c in self.scrollConstraints { c.isActive = true }
      self.lionIconView.alpha = 0
      self.layoutIfNeeded()
    }
    return animator
  }

  // 오프셋 기반 헤더 변환
  func applyHeaderTransform(offset: CGFloat, threshold: CGFloat) {
    let transform: CGAffineTransform = offset > threshold
      ? CGAffineTransform(translationX: 0, y: -(offset - threshold))
      : .identity
    temperatureView.transform = transform
    weatherIconView.transform = transform
  }

  // 상단 요약 갱신 (+ 단위)
  func updateSummary(temp: Int, max: Int, min: Int, feelsLike: Int, unit: TemperatureUnit) {
    tempLabel.text = "\(temp)°\(unit.symbol)"
    tempDetailLabel.text = "↑\(max)° ∙ ↓\(min)°\n체감 온도 \(feelsLike)°"
  }

  // 상단 아이콘/배경 갱신
  func updateTopVisuals(weatherCode: Int, isDayTime: Bool, style: GradientStyle) {
    let weather = topWeatherIllustrationName(for: weatherCode, isDayTime: isDayTime)
    let lion = topLionIllustrationName(for: weatherCode, isDayTime: isDayTime)
    weatherIconView.image = UIImage(named: weather)
    lionIconView.image = UIImage(named: lion)
    backgroundGradient.updateStyle(style, animated: true)
  }
}
