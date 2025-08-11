//
//  HeroView.swift
//  SajaWeather
//
//  Created by 김우성 on 8/8/25.
//

import SwiftUI

struct HeroView: View {
  let progress: CGFloat
  let tempText: String
  
  var body: some View {
    ZStack {
      LinearGradient(colors: [Color.blue.opacity(0.8), Color.indigo],
                                 startPoint: .top, endPoint: .bottom)
      
      VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 12) {
          Image(systemName: "cloud.sun.fill")
            .font(.system(size: 56))
            .foregroundStyle(.white, .yellow)
            .offset(y: -progress * 40)
          
          Spacer()
          
          Text(tempText)
            .font(.system(size: 54, weight: .bold))
            .foregroundColor(.white)
            .offset(x: progress * 80)
        }
        
        Text("↑34° · ↓26°  체감 32°")
          .foregroundStyle(.white.opacity(0.9))
          .offset(x: progress * 60)
      }
      .padding(.horizontal, 20)
      .padding(.top, 12)
      
      Image(systemName: "pawprint.fill") // 나중에 사자로 변경
        .resizable().scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundStyle(.orange)
        .opacity(max(0, 1.0 - progress * 2.0))
        .scaleEffect(max(0.7, 1 - progress * 0.3))
        .offset(y: 80)
    }
    .ignoresSafeArea()
    
    
  }
}

#Preview {
  HeroView(progress: 0, tempText: "32")
}
