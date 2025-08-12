//
//  UICollectionView+.swift
//  SajaWeather
//
//  Created by estelle on 8/12/25.
//

import UIKit

extension UICollectionView {
  func centerIndexPath() -> IndexPath? {
    let centerPoint = CGPoint(
      x: self.center.x + self.contentOffset.x,
      y: self.center.y + self.contentOffset.y
    )
    return self.indexPathForItem(at: centerPoint)
  }
}
