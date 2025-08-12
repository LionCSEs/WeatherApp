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
    case searchTextChanged(String)
    case selectLocation(Location)
    case selectRecentSearch(Location)
    case cancel
  }
  
  enum Mutation {
    case setSearchText(String)
    case setRecentSearches([Location])
    case setSearchResults([Location])
    case setIsLoading(Bool)
    case setSelectedLocation(Location)
    case setShouldDismiss(Bool)
  }
  
  struct State: Then {
    var searchText: String = ""
    var recentSearches: [Location] = []
    var searchResults: [Location] = []
    var isLoading: Bool = false
    var selectedLocation: Location?
    var shouldDismiss: Bool = false
    
    var shouldShowRecentSearches: Bool {
      return searchText.isEmpty && !recentSearches.isEmpty
    }
    
    var shouldShowSearchResults: Bool {
      return !searchText.isEmpty && !searchResults.isEmpty && !isLoading
    }
    
    var shouldShowEmptyState: Bool {
      return searchText.isEmpty && recentSearches.isEmpty
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
  // TODO: init으로 해주는게 나을듯!!!!, 비동기가 아닌거여서 적합하지 않은것같음
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let loadRecentSearches = Observable.just(
      Mutation.setRecentSearches(userDefaultsService.loadRecentSearchLocations())
    )
    return Observable.merge(mutation, loadRecentSearches)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .searchTextChanged(let text):
      let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
      
      if trimmedText.isEmpty {
        return Observable.just(Mutation.setSearchText(trimmedText))
      }
      
      return Observable.concat([
        Observable.just(Mutation.setSearchText(trimmedText)),
        Observable.just(Mutation.setIsLoading(true)),
        locationSearchService.searchCompleter(query: trimmedText)
          .map { Mutation.setSearchResults($0) }
          .catch { _ in Observable.just(Mutation.setSearchResults([])) },
        Observable.just(Mutation.setIsLoading(false))
      ])
      
    case .selectLocation(let location):
      userDefaultsService.addRecentSearchLocation(location)
      return Observable.just(Mutation.setSelectedLocation(location))
      
    case .selectRecentSearch(let location):
      return Observable.just(Mutation.setSelectedLocation(location))
      
    case .cancel:
      return Observable.just(Mutation.setShouldDismiss(true))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setSearchText(let text):
      return state.with {
        $0.searchText = text
        if text.isEmpty {
          $0.searchResults = []
        }
      }
      
    case .setRecentSearches(let locations):
      return state.with {
        $0.recentSearches = locations
      }
      
    case .setSearchResults(let results):
      return state.with {
        $0.searchResults = results
      }
      
    case .setIsLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
      
    case .setSelectedLocation(let location):
      return state.with {
        $0.selectedLocation = location
      }
      
    case .setShouldDismiss(let shouldDismiss):
      return state.with {
        $0.shouldDismiss = shouldDismiss
      }
    }
  }
}
