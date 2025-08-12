//
//  SearchViewReactor.swift
//  SajaWeather
//
//  Created by Milou on 8/12/25.
//

import Foundation
import ReactorKit
import RxSwift
import Then

final class SearchViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case searchBarDidBeginEditing
    case searchBarDidEndEditing
    case searchTextChanged(String)
    case selectLocation(Location)
    case selectRecentSearch(Location)
    case cancelButtonClicked
  }
  
  enum Mutation {
    case setSearchText(String)
    case setRecentSearches([Location])
    case setSearchResults([Location])
    case setSelectedLocation(Location)
    case setShouldDismiss(Bool)
    case setSearchBarFocused(Bool)
    case clearSearch
  }
  
  enum DisplayState {
    case empty           // 초기 사자 이미지
    case recentSearches  // 최근 검색 표시
    case searchResults   // 검색 결과 표시
  }
  
  struct State: Then {
    var searchText: String = ""
    var recentSearches: [Location] = []
    var searchResults: [Location] = []
    var selectedLocation: Location?
    var shouldDismiss: Bool = false
    var isSearchBarFocused: Bool = false
    
    var displayState: DisplayState {
      // 검색어가 있고 결과가 있으면 검색 결과
      if !searchText.isEmpty && !searchResults.isEmpty {
        return .searchResults
      }
      // 검색바가 포커스되었고 검색어가 비어있고 최근 검색이 있으면 최근 검색
      else if isSearchBarFocused && searchText.isEmpty && !recentSearches.isEmpty {
        return .recentSearches
      }
      // 그 외에는 사자 이미지
      else {
        return .empty
      }
    }
  }
  
  let initialState = State()
  
  private let locationSearchService: LocationSearchServiceType
  private let userDefaultsService: UserDefaultsService
  
  init(
    locationSearchService: LocationSearchServiceType,
    userDefaultsService: UserDefaultsService = UserDefaultsService.shared
  ) {
    self.locationSearchService = locationSearchService
    self.userDefaultsService = userDefaultsService
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return Observable.just(
        Mutation.setRecentSearches(userDefaultsService.loadRecentSearchHistory())
      )
      
    case .searchBarDidBeginEditing:
      return Observable.just(Mutation.setSearchBarFocused(true))
      
    case .searchBarDidEndEditing:
      return Observable.just(Mutation.setSearchBarFocused(false))
      
    case .searchTextChanged(let text):
      let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
      
      // 텍스트가 비어있으면 검색 결과만 클리어
      if trimmedText.isEmpty {
        return Observable.concat([
          Observable.just(Mutation.setSearchText(trimmedText)),
          Observable.just(Mutation.setSearchResults([]))
        ])
      }
      
      // 검색 요청
      return Observable.concat([
        Observable.just(Mutation.setSearchText(trimmedText)),
        locationSearchService.searchCompleter(query: trimmedText)
          .map { Mutation.setSearchResults($0) }
          .catch { _ in Observable.just(Mutation.setSearchResults([])) }
      ])
      
    case .selectLocation(let location):
      userDefaultsService.addRecentSearchHistory(location)
      return Observable.just(Mutation.setSelectedLocation(location))
      
    case .selectRecentSearch(let location):
      return Observable.just(Mutation.setSelectedLocation(location))
      
    case .cancelButtonClicked:
      return Observable.concat([
        Observable.just(Mutation.clearSearch),
        Observable.just(Mutation.setSearchBarFocused(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setSearchText(let text):
      return state.with {
        $0.searchText = text
      }
      
    case .setRecentSearches(let locations):
      return state.with {
        $0.recentSearches = locations
      }
      
    case .setSearchResults(let results):
      return state.with {
        $0.searchResults = results
      }
      
    case .setSelectedLocation(let location):
      return state.with {
        $0.selectedLocation = location
      }
      
    case .setShouldDismiss(let shouldDismiss):
      return state.with {
        $0.shouldDismiss = shouldDismiss
      }
      
    case .setSearchBarFocused(let focused):
      return state.with {
        $0.isSearchBarFocused = focused
      }
      
    case .clearSearch:
      return state.with {
        $0.searchText = ""
        $0.searchResults = []
      }
    }
  }
}
