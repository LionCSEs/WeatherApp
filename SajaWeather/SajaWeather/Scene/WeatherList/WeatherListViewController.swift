//
//  WeatherListViewController.swift
//  SajaWeather
//
//  Created by estelle on 8/8/25.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import CoreLocation

class WeatherListViewController: BaseViewController, View {
  // 스크롤이 멈출 때마다 중앙 아이템의 IndexPath를 전달할 Subject
  let centeredIndexPathSubject = PublishSubject<IndexPath>()
  var dataSource: UICollectionViewDiffableDataSource<WeatherListSection, WeatherListItem>!
 // var disposeBag = DisposeBag()
  
  private var gradientBackground = GradientView(style: .unknown)
  
  let imageToggle = ToggleButton(
    leftContent: .image(UIImage(systemName: "square.grid.2x2")),
    rightContent: .image(UIImage(systemName: "list.bullet"))
  )
  
  let tempToggle = ToggleButton(
    leftContent: .text("ºC"),
    rightContent: .text("ºF")
  )
  
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout(for: .grid)).then {
    $0.backgroundColor = .clear
    $0.isScrollEnabled = true
  }
  
  private let plusButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "plus"), for: .normal)
    $0.backgroundColor = .gray.withAlphaComponent(0.3)
    $0.tintColor = .white
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowRadius = 5
    $0.layer.cornerRadius = 25
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    configureDataSource()
    self.reactor = WeatherListViewReactor(
      weatherRepository: WeatherRepository(weatherService: WeatherService())
    )
  }
  
  func bind(reactor: WeatherListViewReactor) {
    
    collectionView.rx.itemSelected
      .map { indexPath in
        if let item = self.dataSource.itemIdentifier(for: indexPath) {
          let location = item.weatherData.address.coordinate
          return AppStep.weatherDetailIsRequired(location)
        }
        return AppStep.weatherDetailIsRequired(CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780))
      }
      .bind(to: steps)
      .disposed(by: disposeBag)
    
    centeredIndexPathSubject
      .distinctUntilChanged()
      .compactMap { [weak self] indexPath -> GradientStyle? in
        guard let item = self?.dataSource.itemIdentifier(for: indexPath) else { return nil }
        return item.weatherData.backgroundStyle
      }
      .distinctUntilChanged()
      .map { Reactor.Action.changeBackgroundStyle($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    Observable.just(())
      .map { Reactor.Action.loadWeather }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    imageToggle.rx.controlEvent(.valueChanged)
      .map { Reactor.Action.toggleLayout }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    let tempToggleTap = UITapGestureRecognizer()
    tempToggle.addGestureRecognizer(tempToggleTap)
    
    tempToggleTap.rx.event
      .map { _ in Reactor.Action.toggleTempUnit }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    plusButton.rx.tap
      .map { AppStep.searchIsRequired }
      .bind(to: steps)
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.weatherItems)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] weatherItems in
        self?.applySnapshot(weatherItems)
      })
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.layoutType)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] layoutType in
        guard let self = self else { return }
        let newLayout = self.createCompositionalLayout(for: layoutType)
        self.collectionView.setCollectionViewLayout(newLayout, animated: true) { _ in
          
          // 빈 스냅샷 적용 → 강제 셀 재생성 유도
          var emptySnapshot = NSDiffableDataSourceSnapshot<WeatherListSection, WeatherListItem>()
          emptySnapshot.appendSections([.main])
          self.dataSource.apply(emptySnapshot, animatingDifferences: true)
          
          // 기존 데이터로 다시 채움
          let currentItems = self.reactor?.currentState.weatherItems ?? []
          self.applySnapshot(currentItems, animated: true)
        }
      })
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.tempUnit)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] tempUnit in
        self?.tempToggle.isLeftSelected = tempUnit == .celsius
      })
      .disposed(by: disposeBag)
    
    reactor.state
      .map(\.backgroundStyle)
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] style in
        self?.gradientBackground.updateStyle(style, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func setupUI() {
    [gradientBackground, tempToggle, imageToggle, collectionView, plusButton].forEach {
      view.addSubview($0)
    }
    
    gradientBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    tempToggle.snp.makeConstraints {
      $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.width.equalTo(75)
      $0.height.equalTo(30)
    }
    
    imageToggle.snp.makeConstraints {
      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.width.equalTo(75)
      $0.height.equalTo(30)
    }
    
    collectionView.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
    collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
    collectionView.snp.makeConstraints {
      $0.top.equalTo(imageToggle.snp.bottom).offset(30)
      $0.leading.bottom.trailing.equalToSuperview()
    }
    
    plusButton.snp.makeConstraints {
      $0.width.height.equalTo(50)
      $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  WeatherListViewController()
}
