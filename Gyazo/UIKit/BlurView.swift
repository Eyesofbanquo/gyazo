//
//  BlurView.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct BlurView: UIViewRepresentable {
  typealias UIViewType = UIVisualEffectView
  
  let style: UIBlurEffect.Style
  
  init(style: UIBlurEffect.Style = .systemMaterial) {
    self.style = style
  }
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: .systemMaterial)
  }
  
  
}
