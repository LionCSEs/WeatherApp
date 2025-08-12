//
//  AppFlow.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import UIKit
import RxFlow
import RxSwift
import Then

final class AppFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }
  
  private lazy var rootViewController = UINavigationController().then {
    $0.setNavigationBarHidden(true, animated: false)
  }
  
  // 의존성
  private lazy var locationService: LocationServiceType = LocationService()
  private lazy var weatherRepository: WeatherRepositoryType = {
    let weatherService: WeatherServiceType = WeatherService()
    return WeatherRepository(weatherService: weatherService)
  }()
  private lazy var locationSearchService: LocationSearchServiceType = LocationSearchService()
  
  func navigate(to step: any Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .weatherDetailIsRequired(let coordinate):
      return navigateToWeatherDetail(coordinate: coordinate)
    case .weatherListIsRequired:
      return navigateToWeatherList()
    case .searchIsRequired:
      return navigateToSearch()
    case .searchIsDismissed(let coordinate):
      return dismissSearchAndUpdateWeather(coordinate: coordinate)
    }
  }
  
  private func navigateToWeatherDetail(coordinate: Coordinate) -> FlowContributors {
    
    // TODO: WeatherDetail Reactor와 ViewController로 수정
    let viewModel = WeatherDetailViewModel(
      locationService: locationService
    )
    
    let viewController = WeatherDetailViewController(viewModel: viewModel)
    
    if rootViewController.viewControllers.isEmpty {
      // 첫 진입
      rootViewController.setViewControllers([viewController], animated: false)
    } else {
      // 기존 WeatherDetail 업데이트
      rootViewController.setViewControllers([viewController], animated: true)
    }
    
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController
    ))
  }
  
  private func navigateToWeatherList() -> FlowContributors {
    
    // TODO: WeatherList Reactor와 ViewController
    /*
     // WeatherList에 필요한 의존성들 주입
     let reactor = WeatherListReactor(
     weatherRepository: weatherRepository,
     locationService: locationService
     )
     let viewController = x(reactor: reactor)
     viewController.modalPresentationStyle = .fullScreen
     
     rootViewController.present(viewController, animated: true)
     
     return .one(flowContributor: .contribute(
     withNextPresentable: viewController,
     withNextStepper: viewController
     ))
     */
    
    // 임시 구현
    let tempViewController = UIViewController()
    tempViewController.view.backgroundColor = .systemBlue
    tempViewController.modalPresentationStyle = .fullScreen
    
    rootViewController.present(tempViewController, animated: true)
    return .none
  }
  
  private func navigateToSearch() -> FlowContributors {
    // TODO: Search Reactor와 ViewController
    /*
     // Search에 필요한 의존성 주입
     let reactor = SearchReactor(
     locationSearchService: locationSearchService
     )
     let viewController = SearchViewController(reactor: reactor)
     viewController.modalPresentationStyle = .fullScreen
     
     rootViewController.present(viewController, animated: true)
     
     return .one(flowContributor: .contribute(
     withNextPresentable: viewController,
     withNextStepper: viewController
     ))
     */
    
    // 임시 구현
    let tempViewController = UIViewController()
    tempViewController.view.backgroundColor = .systemGreen
    tempViewController.modalPresentationStyle = .fullScreen
    
    rootViewController.present(tempViewController, animated: true)
    return .none
  }
  
  private func dismissSearchAndUpdateWeather(coordinate: Coordinate?) -> FlowContributors {
    rootViewController.dismiss(animated: true) { [weak self] in
      if let coordinate = coordinate {
        // 선택된 위치로 WeatherDetail 업데이트
        _ = self?.navigateToWeatherDetail(coordinate: coordinate)
      }
      // coordinate가 nil이면 그냥 dismiss만 (선택하지 않고 취소
    }
    return .none
  }
}
