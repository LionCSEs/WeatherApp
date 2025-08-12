//
//  WeatherDetailViewController.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class WeatherDetailViewController: BaseViewController, View {
  private let contentView = WeatherDetailView()
  private lazy var dataSourceProvider = WeatherDetailDataSourceProvider(collectionView: contentView.collectionView)
  private var scrollAnimator: UIViewPropertyAnimator?
  
  init(reactor: WeatherDetailReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func loadView() { view = contentView }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 배경은 GradientView 가 처리
    contentView.registerDecoration()
    dataSourceProvider.applyInitialSnapshot()
    scrollAnimator = contentView.makeScrollAnimator()
    bindScroll()
    
    contentView.listButton.rx.tap
      .map { AppStep.weatherListIsRequired }
      .bind(to: steps)
      .disposed(by: disposeBag)
    
    contentView.searchButton.rx.tap
      .map { AppStep.searchIsRequired }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
  
  func bind(reactor: WeatherDetailReactor) {
    // 위치 요청
    rx.viewDidAppear
      .take(1)
      .map { _ in WeatherDetailReactor.Action.requestLocation }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 단위 불러와서 날씨 요청
    rx.viewDidAppear
      .take(1)
      .map { _ in UserDefaultsService.shared.loadTemperatureUnitEnum() }
      .map(WeatherDetailReactor.Action.requestWeather)
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 결과 바인딩
    reactor.state
      .map(\.currentWeather)
      .distinctUntilChanged { $0?.temperature == $1?.temperature }
      .compactMap { $0 }
      .observe(on: MainScheduler.instance)
      .bind(onNext: { [weak self] weather in
        guard let self else { return }
        // 상단 요약 (단위 반영)
        let unit = UserDefaultsService.shared.loadTemperatureUnitEnum()
        self.contentView.updateSummary(
          temp: weather.temperature,
          max: weather.maxTemp,
          min: weather.minTemp,
          feelsLike: weather.feelsLikeTemp,
          unit: unit
        )
        // 상단 아이콘 + 배경 그라데이션
        self.contentView.updateTopVisuals(
          weatherCode: weather.icon,
          isDayTime: weather.isDayNow,
          style: weather.backgroundStyle
        )
        // 리스트
        self.dataSourceProvider.apply(weather: weather, animated: true)
      })
      .disposed(by: disposeBag)
    
    reactor.pulse(\.$error)
      .compactMap { $0 }
      .observe(on: MainScheduler.instance)
      .bind(onNext: { [weak self] error in
        self?.presentLocationError(error)
      })
      .disposed(by: disposeBag)
  }
  
  private func bindScroll() {
    rx.viewDidAppear
      .take(1)
      .bind(onNext: { [weak self] _ in
        self?.scrollAnimator?.startAnimation()
        self?.scrollAnimator?.pauseAnimation()
      })
      .disposed(by: disposeBag)
    
    contentView.collectionView.rx.didScroll
      .skip(until: rx.viewDidAppear)
      .withUnretained(contentView.collectionView)
      .map { cv, _ in cv.contentOffset.y + cv.adjustedContentInset.top }
      .distinctUntilChanged()
      .bind(onNext: { [weak self] offset in
        guard let self, let animator = self.scrollAnimator else { return }
        let threshold: CGFloat = 320
        animator.fractionComplete = min(1, max(0, offset / threshold))
        self.contentView.applyHeaderTransform(offset: offset, threshold: threshold)
      })
      .disposed(by: disposeBag)
  }
  
  private func presentLocationError(_ error: LocationError) {
    let alert = UIAlertController(title: "위치 오류", message: error.localizedDescription, preferredStyle: .alert)
    if case .authorizationDenied = error {
      alert.addAction(.init(title: "설정 열기", style: .default) { _ in
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
      })
    } else if case .locationServicesDisabled = error {
      alert.addAction(.init(title: "설정 열기", style: .default) { _ in
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
      })
    }
    alert.addAction(.init(title: "확인", style: .cancel))
    present(alert, animated: true)
  }
}
