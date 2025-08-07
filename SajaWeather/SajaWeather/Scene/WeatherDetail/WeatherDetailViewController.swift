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

final class WeatherDetailViewController: UIViewController {
  private let viewModel: WeatherDetailViewModel
  private let disposeBag = DisposeBag()
  private let button = UIButton(type: .system)
  
  init(viewModel: WeatherDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    button.setTitle("위치 가져오기", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    
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
