# 🦁 SajaWeather 

## 🗓️ 프로젝트 기간
2025년 8월 5일 ~ 8월 13일

## 📱 주요 기능

- OpenWeatherMap의 4개의 API 를 호출해 통합 관리하는 구조
    - Current Weather Data, Hourly Forecast 4 days, Daily Forecast 16 days, Air Pollution
- 앱 진입 시 사용자 위치 권한 요청 및 그에 따른 분기
- 날씨 상세 화면
    - 날씨에 따라 다르게 보여지는 움직이는 날씨 아이콘 / 상징적인 사자 캐릭터 / 날씨 정보
    - 일출-일몰 시간 내 여부에 따라 다르게 보여지는 그라데이션 배경 색상 / 움직이는 날씨 아이콘 / 사자 캐릭터 / 여러 섹션의 날씨 아이콘
    - 자세한 정보를 확인하기 위해 스크롤하면 자연스럽게 재배치되는 대표 날씨 정보와 아이콘, 사라지는 사자 캐릭터
    - 각각 다른 레이아웃으로 유려하게 보여지는 시간별 예보 / 일별 예보 / 대기 정보 / 일출-일몰 시간 섹션
    - 좌상단 메뉴 버튼을 통해 날씨 목록 화면 진입
- 날씨 목록 화면
    - 상단 섭씨 /  화씨 및 카드형 / 리스트형 토글 설정
    - 우측 하단 플러스 버튼을 통해 새로운 지역의 날씨 추가
    - 해당 지역의 날씨에 따라 다르게 보여지는 그라데이션 배경 색상
- 검색 및 추가 화면
    - 초기 상태, 최근 검색, 검색 결과 상태에 따른 3단계 상태 별 UI 전환
    - 사용자 입력에 따른 실시간 주소 자동완성 제안

## 🏗️ 아키텍처

### MVVM-C (ReactorKit + RxFlow) 패턴

```
AppFlow (루트)
├── SearchFlow ↔ SearchViewController/SearchViewReactor
├── WeatherDetailFlow ↔ WeatherDetailViewController/WeatherDetailReactor
└── WeatherListFlow ↔ WeatherListViewController/WeatherListViewReactor
```

#### 주요 설계 원칙
- RxFlow Pattern: Step 기반 선언적 네비게이션과 의존성 주입 담당
- ReactorKit: 단방향 데이터 플로우 (Action → Mutation → State → View)
- Repository Pattern: 네트워크와 로컬 데이터 추상화
- Protocol 기반 설계: Service Protocol을 통한 일관된 구조

#### 주요 컴포넌트 역할
**App Layer**
- `AppFlow`:앱 전체 네비게이션 관리 (Step → FlowContributors)
- `AppStep`: 화면 전환 이벤트 정의
- `BaseViewController`: RxFlow Stepper를 구현한 공통 베이스

**Data Layer**
- `WeatherService`: OpenWeatherMap API 통신 (Moya 기반)
- `WeatherRepository`: 날씨 데이터 추상화 계층
- `LocationService`: CoreLocation 기반 위치 서비스
- `LocationSearchService`: MapKit 기반 위치 검색 (MKLocalSearchCompleter)
- `UserDefaultsService`: 앱 설정 및 저장된 위치 관리
- `CurrentWeather`: 현재 날씨 + 시간별/일별 예보 통합 엔티티
- `Location`: 위치 정보 (제목, 부제목, 좌표) 엔티티

**Presentation Layer**
- `ViewControllers`: 화면 표시 및 사용자 입력 처리
- `Reactors`: 비즈니스 로직 및 상태 관리 (ReactorKit 패턴)
- `Custom Components`: 재사용 가능한 UI 컴포넌트 (GradientView 등)



## 📁 프로젝트 구조

```
SajaWeather/
├── App/                          # 앱 설정 및 Flow
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Flow/                     # 화면 전환 관리
│       ├── AppFlow.swift
│       ├── AppStep.swift
│       └── BaseViewController.swift
├── Data/                         # 데이터 레이어
│   ├── Model/                    # 도메인 모델 및 DTO
│   │   ├── DTO/                  # API 응답 DTO
│   │   ├── Location/             # 위치 관련 모델
│   │   └── Weather/              # 날씨 관련 모델
│   └── Service/                  # 데이터 소스 관리
│       ├── Location/             # 위치 서비스
│       ├── Weather/              # 날씨 API 서비스
│       └── Storage/              # 로컬 저장소
├── Scene/                        # 프레젠테이션 레이어
│   ├── Search/                   # 검색 화면
│   │   ├── SearchViewController.swift
│   │   └── SearchViewReactor.swift
│   ├── WeatherDetail/            # 날씨 상세 화면
│   │   ├── WeatherDetailViewController.swift
│   │   ├── WeatherDetailReactor.swift
│   │   └── View/                 # 상세 화면 컴포넌트들
│   ├── WeatherList/              # 날씨 목록 화면
│   │   ├── WeatherListViewController.swift
│   │   └── WeatherListViewReactor.swift
│   └── Common/                   # 공통 UI 컴포넌트
│       ├── GradientView.swift
│       └── GradientStyle.swift
├── Resource/                     # 리소스 파일
│   ├── Assets.xcassets
│   ├── Lottie/                   # 날씨 애니메이션
│   └── StubData/                 # 개발용 Mock 데이터
└── Utils/                        # 유틸리티
    └── Extensions/               # Swift 확장
```

## 🏃 역할 분담
|      팀원      | 역할                                                       |
|---------------|------------------------------------------------------------|
|     박주하     |     UI 디자인, 날씨 목록 화면(WeatherListView&Reactor), UserDefaultsService, Gradient, Lottie 작업     |
|     양지영     |     Flow, LocationSearchService, Service/Weather, Search, 전체적인 설계 및 아키텍처 채택 (ReactorKit + RxFlow, Repository)     |
|     김우성     |     WeatherDetailView&Reactor, WeatherIconManager, LocationService, 그 외 Date 관련 수정     |


## 🛠️ 기술 스택
- Swift 5
- UIKit
- ReactorKit
- RxSwift/RxCocoa
- RxFlow
- SnapKit
- Then
- Moya/RxMoya
- CoreLocation + MapKit
- UserDefaults
