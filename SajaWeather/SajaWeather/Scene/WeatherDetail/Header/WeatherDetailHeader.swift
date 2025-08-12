//
//  WeatherDetailHeader.swift
//  SajaWeather
//
//  Created by 김우성 on 8/11/25.
//

import SwiftUI
import HostingView

@dynamicMemberLookup
class WeatherDetailHeaderView: UICollectionReusableView {
  
  subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
    get { contentView.state[keyPath: keyPath] }
    set { contentView.state[keyPath: keyPath] = newValue }
  }
  
  private let contentView: StatefulHostingView<State>
  
  struct State {
    var icon: String
    var title: String
    var additional: String?
  }
  
  override init(frame: CGRect) {
    self.contentView = StatefulHostingView(state: State(icon: "", title: "", additional: nil)) {
      state in
      WeatherDetailHeader(state: state)
    }
    super.init(frame: frame)
    addSubview(contentView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  struct WeatherDetailHeader: View {
    let state: State
    
    var body: some View {
      VStack {
        HStack {
          Image(systemName: state.icon)
            .resizable()
            .foregroundStyle(.white)
            .frame(width: 13.5, height: 13.5)
          Text(state.title)
            .font(.system(size: 12))
            .foregroundStyle(.white)
          Spacer()
          if let description = state.additional {
            Text(description)
              .font(.system(size: 12))
              .foregroundStyle(.white)
          }
        }
        Divider()
      }
    }
  }
}


//
//#Preview {
//  WeatherDetailHeader(icon: "clock", title: "시간별 예보", description: nil)
//  WeatherDetailHeader(icon: "calendar", title: "일별 예보", description: "최고  ∙  최저")
//}
