//
//  WeatherDetailLayout.swift
//  SajaWeather
//
//  Created by 김우성 on 8/12/25.
//

import UIKit

enum WeatherDetailLayoutProvider {
  static func makeLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
      let contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(45)),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "weatherDetail-background")
      backgroundItem.contentInsets = contentInsets

      switch sectionIndex {
      case 0: // hourly
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .absolute(50), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .absolute(50), heightDimension: .absolute(133)),
          subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 15, bottom: 20, trailing: 15)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 15
        section.decorationItems = [backgroundItem]
        return section

      case 1: // daily
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(38))
        )
        let group = NSCollectionLayoutGroup.vertical(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(38)),
          subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 15, bottom: 20, trailing: 15)
        section.interGroupSpacing = 5
        section.boundarySupplementaryItems = [header]
        section.decorationItems = [backgroundItem]
        return section

      case 2: // air
        let spacing: CGFloat = 20
        let containerWidth = (environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing)
        let itemWidth = (containerWidth - spacing * 2) / 3
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .absolute(itemWidth), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(68)),
          repeatingSubitem: item, count: 3
        )
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        return section

      default: // sunCycle
        let item = NSCollectionLayoutItem(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        let group = NSCollectionLayoutGroup.horizontal(
          layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(68)),
          subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        section.decorationItems = [backgroundItem]
        return section
      }
    }
    layout.register(WeatherBackgroundView.self, forDecorationViewOfKind: "weatherDetail-background")
    return layout
  }
}
