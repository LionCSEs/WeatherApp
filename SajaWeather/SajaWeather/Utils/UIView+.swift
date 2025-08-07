//
//  UIView+.swift
//  SajaWeather
//
//  Created by estelle on 8/7/25.
//

import UIKit

extension UIView {
  func applyGradient(style: GradientStyle) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = bounds
    gradientLayer.colors = style.colors.map(\.cgColor)
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    
    layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    layer.insertSublayer(gradientLayer, at: 0)
  }
}
