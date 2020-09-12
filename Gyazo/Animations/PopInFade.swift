//
//  PopInFade.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/7/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

extension AnyTransition {
  
  static func popInFade(scaleBy by: CGFloat = 1.0) -> AnyTransition {
    .asymmetric(insertion: AnyTransition.scale(scale: by)
                  .combined(with: .opacity),
                removal: .opacity)
  }
}
