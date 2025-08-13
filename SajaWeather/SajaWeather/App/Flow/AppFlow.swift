//
//  AppFlow.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import UIKit
import RxFlow
import RxSwift

final class AppFlow: Flow {
  var root: Presentable {
    return self.window
  }
  private let window: UIWindow
  private let rootViewController: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.setNavigationBarHidden(true, animated: false)
    return navigationController
  }()
  
  // MARK: - Dependencies
  
  private let locationService: LocationServiceType = LocationService()
  private let weatherRepository: WeatherRepositoryType = {
    let weatherService: WeatherServiceType = WeatherService()
    return WeatherRepository(weatherService: weatherService)
  }()
  private let locationSearchService: LocationSearchServiceType = LocationSearchService()
  
  // MARK: - Initializer
  
  init(window: UIWindow) {
     self.window = window
     self.window.rootViewController = rootViewController
     self.window.makeKeyAndVisible()
   }
  
  func navigate(to step: any Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .weatherDetailIsRequired(let location):
      return navigateToWeatherDetail(location: location)
    case .weatherListIsRequired:
      return navigateToWeatherList()
    case .searchIsRequired:
      return navigateToSearch()
    case .searchIsDismissed(let location):
      return dismissSearchAndUpdateWeather(location: location)
    }
  }
  
  private func navigateToWeatherDetail(location: Location) -> FlowContributors {
    
    let detailViewController = WeatherDetailViewController(
      reactor: WeatherDetailReactor(
        locationService: self.locationService,
        weatherRepository: self.weatherRepository
      )
    )

    if rootViewController.viewControllers.isEmpty {
      // 첫 진입
      let listViewController = WeatherListViewController(
        reactor: WeatherListViewReactor(
          weatherRepository: self.weatherRepository
        )
      )
      rootViewController
        .setViewControllers([listViewController, detailViewController], animated: false)
      return .multiple(flowContributors: [
        .contribute(
          withNextPresentable: listViewController,
          withNextStepper: listViewController
        ),
        .contribute(
          withNextPresentable: detailViewController,
          withNextStepper: detailViewController
        )
      ])
    } else {
      rootViewController.pushViewController(detailViewController, animated: true)
      return .one(flowContributor: .contribute(
        withNextPresentable: detailViewController,
        withNextStepper: detailViewController
      ))
    }
  }
  
  private func navigateToWeatherList() -> FlowContributors {
    rootViewController.popViewController(animated: true)
    return .none
  }
  
  private func navigateToSearch() -> FlowContributors {
     let reactor = SearchViewReactor(
     locationSearchService: locationSearchService
     )
     let viewController = SearchViewController(reactor: reactor)
     viewController.modalPresentationStyle = .fullScreen
     
    if let presentedViewController = rootViewController.presentedViewController {
            presentedViewController.present(viewController, animated: true)
        } else {
            rootViewController.present(viewController, animated: true)
        }
     
     return .one(flowContributor: .contribute(
     withNextPresentable: viewController,
     withNextStepper: viewController
     ))
  }
  
  private func dismissSearchAndUpdateWeather(location: Location?) -> FlowContributors {
    rootViewController.dismiss(animated: true) { [weak self] in
      if let location = location {
            // 선택된 위치로 WeatherDetail 업데이트
            _ = self?.navigateToWeatherDetail(location: location)
          }
      // coordinate가 nil이면 그냥 dismiss만 (선택하지 않고 취소
    }
    return .none
  }
}
