//
//  GradientView.swift
//  SajaWeather
//
//  Created by estelle on 8/8/25.
//

import UIKit

class GradientView: UIView {
  private let gradientLayer = CAGradientLayer()
  private var style: GradientStyle
  
  init(style: GradientStyle) {
    self.style = style
    super.init(frame: .zero)
    setupGradient()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupGradient() {
    gradientLayer.colors = style.colors.map(\.cgColor)
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    layer.insertSublayer(gradientLayer, at: 0)
  }
  
  func updateStyle(_ newStyle: GradientStyle, animated: Bool = false) {
    self.style = newStyle
    let newColors = newStyle.colors.map(\.cgColor)
    
    if animated {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.4)
      gradientLayer.colors = newColors
      CATransaction.commit()
    } else {
      gradientLayer.colors = newColors
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }
}
