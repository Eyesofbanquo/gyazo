//
//  TableViewModifier.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/12/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct TableView: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .listRowInsets(EdgeInsets())
      .background(Color(.systemBackground))
  }
}
