//
//  ListSeparatorStyleNoneModifier.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

public struct ListSeparatorStyleNoneModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content.onAppear {
      UITableView.appearance().separatorStyle = .none
    }.onDisappear {
      UITableView.appearance().separatorStyle = .singleLine
    }
  }
}

extension View {
  public func listSeparatorStyleNone() -> some View {
    modifier(ListSeparatorStyleNoneModifier())
  }
}
