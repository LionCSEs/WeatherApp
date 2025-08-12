//
//  BaseViewController.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import UIKit
import RxFlow
import RxRelay
import RxSwift

class BaseViewController: UIViewController, Stepper {
  let steps = PublishRelay<Step>()
  var disposeBag = DisposeBag()
}
