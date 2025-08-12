//
//  WeatherListViewController+.swift
//  SajaWeather
//
//  Created by estelle on 8/12/25.
//

import UIKit

extension WeatherListViewController {
  func configureDataSource() {
    dataSource = UICollectionViewDiffableDataSource<WeatherListSection, WeatherListItem>(collectionView: collectionView) { [weak self] (
      collectionView,
      indexPath,
      weatherItem
    ) -> UICollectionViewCell? in
      guard let self = self else { return UICollectionViewCell() }
      
      // 현재 레이아웃 타입에 따라 다른 셀 반환
      switch self.reactor?.currentState.layoutType {
      case .grid:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as? GridCell else {
          return UICollectionViewCell()
        }
        cell
          .configure(
            with: weatherItem.weatherData,
            tempUnit: self.reactor?.currentState.tempUnit ?? .celsius
          )
        return cell
        
      case .list:
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.identifier, for: indexPath) as? ListCell else {
          return UICollectionViewCell()
        }
        cell.configure(
          with: weatherItem.weatherData,
          tempUnit: self.reactor?.currentState.tempUnit ?? .celsius
        )
        return cell
      case .none:
        return UICollectionViewCell()
      }
    }
  }
  
  func applySnapshot(_ items: [WeatherListItem], animated: Bool = true) {
    guard let dataSource = dataSource else { return }
    var snapshot = NSDiffableDataSourceSnapshot<WeatherListSection, WeatherListItem>()
    snapshot.appendSections([.main])
    snapshot.appendItems(items, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: animated)
  }
  
  func createCompositionalLayout(for type: LayoutType) -> UICollectionViewCompositionalLayout {
    
    return UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, _ in
      // 레이아웃 처리
      switch type {
      case .grid:
        return self.createGridLayout()
      case .list:
        return self.createListLayout()
      }
    })
  }
  
  func createGridLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(600))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPagingCentered
    section.interGroupSpacing = UIScreen.main.bounds.width * 0.06
    
    // 수평 스크롤 시 호출될 핸들러 설정
    section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, scrollOffset, layoutEnvironment) in
      // 스크롤이 멈추었을 때만 중앙 IndexPath를 찾음
      // isDragging, isDecelerating을 통해 스크롤이 끝났는지 확인
      guard let self = self, !self.collectionView.isDragging, !self.collectionView.isDecelerating else { return }
      
      // 중앙 IndexPath를 찾아서 Subject로 전달
      if let centerIndexPath = self.collectionView.centerIndexPath() {
        self.centeredIndexPathSubject.onNext(centerIndexPath)
      }
    }
    
    return section
  }
  
  func createListLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .absolute(134))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 30
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
    
    return section
  }
}
