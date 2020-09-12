//
//  NavbarIconModifier.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/7/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct NavbarIconModifier: ViewModifier {

  func body(content: Content) -> some View {
    content
      .font(.title)
      .contentShape(Rectangle())
  }
  
}

extension View {
  func navbarIconify() -> some View {
    self.modifier(NavbarIconModifier())
  }
}
