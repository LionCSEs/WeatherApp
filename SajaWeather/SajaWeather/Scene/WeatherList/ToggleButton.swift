//
//  ToggleButton.swift
//  SajaWeather
//
//  Created by estelle on 8/11/25.
//

import UIKit
import Then
import SnapKit

enum ToggleContentType {
  case image(UIImage?)
  case text(String)
}

class ToggleButton: UIControl {
  
  var isLeftSelected: Bool = true {
    didSet {
      // 상태 변경 시에만 UI와 이벤트 갱신
      if oldValue != isLeftSelected {
        updateSelectionIndicatorPosition(animated: true)
        updateSelectionStyles()
        sendActions(for: .valueChanged)
      }
    }
  }
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .gray.withAlphaComponent(0.3)
  }
  private let selectionIndicator = UIView().then {
    $0.backgroundColor = .white.withAlphaComponent(0.4)
  }
  
  // 각 옵션을 담을 컨테이너 뷰
  private let leftOptionView = UIView()
  private let rightOptionView = UIView()
  
  private lazy var stackView = UIStackView(arrangedSubviews: [leftOptionView, rightOptionView]).then {
    $0.distribution = .fillEqually
  }
  
  // 옵션 컨텐츠 저장
  private var leftContent: ToggleContentType
  private var rightContent: ToggleContentType
  
  // MARK: - Initialization
  
  init(leftContent: ToggleContentType, rightContent: ToggleContentType) {
    self.leftContent = leftContent
    self.rightContent = rightContent
    super.init(frame: .zero)
    
    setupUI()
    setupGesture()
    updateSelectionStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius = bounds.height / 2
    backgroundView.layer.cornerRadius = cornerRadius
    selectionIndicator.layer.cornerRadius = cornerRadius
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    [backgroundView, selectionIndicator, stackView].forEach { addSubview($0) }
    
    backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
    stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    
    // 좌/우 옵션에 컨텐츠 적용
    setupOptionView(leftOptionView, for: leftContent)
    setupOptionView(rightOptionView, for: rightContent)
    
    // 선택 인디케이터 초기 위치
    selectionIndicator.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.5)
      $0.centerX.equalTo(leftOptionView.snp.centerX)
    }
  }
  
  private func setupOptionView(_ containerView: UIView, for contentType: ToggleContentType) {
    containerView.subviews.forEach { $0.removeFromSuperview() }
    
    let contentView: UIView
    switch contentType {
    case .image(let image):
      let imageView = UIImageView(image: image)
      imageView.contentMode = .center
      contentView = imageView
    case .text(let text):
      let label = UILabel()
      label.text = text
      label.textAlignment = .center
      label.font = .systemFont(ofSize: 16, weight: .semibold)
      contentView = label
    }
    
    containerView.addSubview(contentView)
    contentView.snp.makeConstraints { $0.center.equalToSuperview() }
  }
  
  // 텍스트/아이콘 색상
  private func updateSelectionStyles() {
    if let leftContentView = leftOptionView.subviews.first {
      if let label = leftContentView as? UILabel {
        label.textColor = .white
      } else if let imageView = leftContentView as? UIImageView {
        imageView.tintColor = .white
      }
    }
    
    if let rightContentView = rightOptionView.subviews.first {
      if let label = rightContentView as? UILabel {
        label.textColor = .white
      } else if let imageView = rightContentView as? UIImageView {
        imageView.tintColor = .white
      }
    }
  }
  
  // MARK: - Actions & Animation
  private func setupGesture() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: self)
    isLeftSelected = (location.x < bounds.width / 2)
  }
  
  // 선택 인디케이터 애니메이션 이동
  private func updateSelectionIndicatorPosition(animated: Bool) {
    let targetView = isLeftSelected ? leftOptionView : rightOptionView
    
    selectionIndicator.snp.remakeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.5)
      $0.centerX.equalTo(targetView.snp.centerX)
    }
    
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
      self.layoutIfNeeded()
    }
  }
}
