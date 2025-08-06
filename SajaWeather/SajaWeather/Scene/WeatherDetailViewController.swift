//
//  WeatherDetailViewController.swift
//  SajaWeather
//
//  Created by 김우성 on 8/6/25.
//

import UIKit
import RxSwift

class WeatherDetailViewController: UIViewController {
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    LocationService.shared.getLocation()
        .subscribe(onNext: { location in
          print("사용자 위치: \(location.coordinate)")
        }, onError: { error in
            print("위치 권한이 거부됨: \(error)")
        })
        .disposed(by: disposeBag)
  }
}
