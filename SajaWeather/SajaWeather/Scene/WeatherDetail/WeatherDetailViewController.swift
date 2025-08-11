//
//  WeatherDetailViewController.swift
//  SajaWeather
//
//  Created by 김우성 on 8/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import Then
import SnapKit

/// Weather Detail Section
enum WDSection: Hashable {
  
}

enum WDItem: Hashable {
  
}

final class WeatherDetailViewController: UIViewController {
  private let weatherDetailView = WeatherDetailView()
  private let viewModel: WeatherDetailViewModel
  private var dataSource: UICollectionViewDiffableDataSource<WDSection, WDItem>!
  private let disposeBag = DisposeBag()
  
  private let button = UIButton(configuration: .filled()).then {
    $0.setTitle("위치 가져오기", for: .normal)
  }
  
  init(viewModel: WeatherDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    bind()
  }
  
  private func configureUI() {
    view.backgroundColor = .systemBackground
    
    view.addSubview(button)
    button.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func bind() {
    button.rx.tap
      .map { WeatherDetailViewModel.Action.requestLocation }
      .bind(to: viewModel.action)
      .disposed(by: disposeBag)
    
    viewModel.stateRelay
      .subscribe(onNext: { [weak self] state in
        if let location = state.location {
          print("위치 수신: \(location.coordinate)")
        } else if let error = state.error {
          print("위치 오류: \(error.localizedDescription)")
          self?.showAlert(error.localizedDescription)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func showAlert(_ message: String) {
    let alert = UIAlertController(title: "위치 오류", message: message, preferredStyle: .alert)
    alert.addAction(.init(title: "확인", style: .default))
    present(alert, animated: true)
  }
}
