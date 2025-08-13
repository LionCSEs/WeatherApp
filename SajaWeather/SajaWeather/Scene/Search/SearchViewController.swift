//
//  SearchViewController.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class SearchViewController: BaseViewController, View {
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .black
  }
  
  private let overlayView = UIView().then {
    $0.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
  }
  
  private let searchBar = UISearchBar().then {
    $0.placeholder = "지역 검색"
    $0.searchBarStyle = .minimal
    $0.backgroundColor = .clear
    $0.tintColor = .white
    
    $0.searchTextField.leftView?.tintColor = .white
    $0.searchTextField.borderStyle = .none
    $0.searchTextField.backgroundColor = .clear
    $0.searchTextField.layer.cornerRadius = 10
    $0.searchTextField.layer.borderWidth = 2
    $0.searchTextField.layer.borderColor = UIColor.white.cgColor
    $0.searchTextField.textColor = .white
    $0.searchTextField.font = .systemFont(ofSize: 16)
    
    $0.searchTextField.attributedPlaceholder = NSAttributedString(
      string: "지역 검색",
      attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
    )
  }
  
  private let recentSearchLabel = UILabel().then {
    $0.text = "최근 검색"
    $0.textColor = .lightGray
    $0.font = .systemFont(ofSize: 12, weight: .medium)
  }
  
  private let tableView = UITableView().then {
    $0.backgroundColor = .clear
    $0.separatorStyle = .none
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
  
  private let searchLionImageView = UIImageView().then {
    $0.image = UIImage(named: "search_lion")
    $0.contentMode = .scaleAspectFit
  }
  
  private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
    $0.color = .white
    $0.hidesWhenStopped = true
  }
  
  init(reactor: SearchViewReactor) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    reactor?.action.onNext(.viewDidLoad)
  }
  
  private func setupUI() {
    view.addSubview(backgroundView)
    view.addSubview(overlayView)
    
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    overlayView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    [searchBar, recentSearchLabel, tableView, searchLionImageView, loadingIndicator]
      .forEach { overlayView.addSubview($0) }
    
    searchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      $0.horizontalEdges.equalToSuperview().inset(20)
      $0.height.equalTo(54)
    }
    
    recentSearchLabel.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(20)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(recentSearchLabel.snp.bottom)
      $0.horizontalEdges.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
    
    searchLionImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(200)
    }
    
    loadingIndicator.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  func bind(reactor: SearchViewReactor) {
    bindActions(reactor)
    bindStates(reactor)
  }
  
  private func bindActions(_ reactor: SearchViewReactor) {
    // 검색바 포커스 시작
    searchBar.rx.textDidBeginEditing
      .map { Reactor.Action.searchBarDidBeginEditing }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 검색바 포커스 종료
    searchBar.rx.textDidEndEditing
      .map { Reactor.Action.searchBarDidEndEditing }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    searchBar.rx.cancelButtonClicked
      .map { Reactor.Action.cancelButtonClicked }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 검색어 변경
    searchBar.rx.text.orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.searchTextChanged($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .withLatestFrom(reactor.state) { indexPath, state in
        let items: [Location] = {
          switch state.displayState {
          case .recentSearches:
            return state.recentSearches
          case .searchResults:
            return state.searchResults
          case .empty:
            return []
          }
        }()
        return (indexPath, state.displayState, items)
      }
      .bind { [weak self] indexPath, displayState, items in
        self?.handleCellSelection(
          at: indexPath,
          displayState: displayState,
          items: items,
          reactor: reactor
        )
      }
      .disposed(by: disposeBag)
  }
  
  private func bindStates(_ reactor: SearchViewReactor) {
    reactor.state.map(\.displayState)
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .bind { [weak self] state in
        self?.updateUI(for: state)
      }
      .disposed(by: disposeBag)
    
    reactor.state.map(\.isSearchBarFocused)
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .bind { [weak self] isFocused in
        self?.searchBar.showsCancelButton = isFocused
        if !isFocused {
          self?.searchBar.resignFirstResponder()
        }
      }
      .disposed(by: disposeBag)
    
    reactor.state.map(\.searchText)
      .distinctUntilChanged()
      .observe(on: MainScheduler.instance)
      .bind { [weak self] text in
        if self?.searchBar.text != text {
          self?.searchBar.text = text
        }
      }
      .disposed(by: disposeBag)
    
    // 테이블뷰 데이터 바인딩
    reactor.state.map { state -> [String] in
      switch state.displayState {
      case .recentSearches:
        return state.recentSearches.map(\.fullAddress)
      case .searchResults:
        return state.searchResults.map(\.fullAddress)
      case .empty:
        return []
      }
    }
    .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { _, address, cell in
      self.configureCell(cell, with: address)
    }
    .disposed(by: disposeBag)
    
    // 화면 전환 처리
    reactor.state.map(\.selectedLocation)
      .compactMap { $0 }
      .take(1)
      .map { AppStep.searchIsDismissed($0) }
      .bind(to: steps)
      .disposed(by: disposeBag)
  }
  
  private func updateUI(for displayState: SearchViewReactor.DisplayState) {
    switch displayState {
    case .empty:
      recentSearchLabel.isHidden = true
      tableView.isHidden = true
      searchLionImageView.isHidden = false
      
    case .recentSearches:
      recentSearchLabel.isHidden = false
      tableView.isHidden = false
      searchLionImageView.isHidden = true
      
    case .searchResults:
      recentSearchLabel.isHidden = true
      tableView.isHidden = false
      searchLionImageView.isHidden = true
    }
  }
  
  private func configureCell(_ cell: UITableViewCell, with address: String) {
    var content = cell.defaultContentConfiguration()
    content.text = address
    content.textProperties.color = .white
    cell.contentConfiguration = content
    cell.backgroundColor = .clear
  }
  
  private func handleCellSelection(
    at indexPath: IndexPath,
    displayState: SearchViewReactor.DisplayState,
    items: [Location],
    reactor: SearchViewReactor
  ) {
    guard indexPath.row < items.count else { return }
    
    let selectedLocation = items[indexPath.row]
    tableView.deselectRow(at: indexPath, animated: true)
    
    let action: SearchViewReactor.Action = {
      switch displayState {
      case .recentSearches:
        return .selectRecentSearch(selectedLocation)
      case .searchResults:
        return .selectLocation(selectedLocation)
      case .empty:
        return .selectLocation(selectedLocation)
      }
    }()
    
    reactor.action.onNext(action)
  }
}
