//
//  RxCocoa+Extension.swift
//  WeatherCollectionView
//
//  Created by 정재성 on 8/11/25.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
  var viewDidLoad: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewWillAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewWillAppear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewIsAppearing: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewIsAppearing(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidAppear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewWillDisappear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidDisappear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewDidLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var didReceiveMemoryWarning: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
    return ControlEvent(events: source)
  }
}
