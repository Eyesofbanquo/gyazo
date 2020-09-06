//
//  AppState.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/5/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class AppState {
  
}


struct AppStateKey: EnvironmentKey {
  static let defaultValue: AppState = AppState()
}


extension EnvironmentValues {
  var appState: AppState {
    get { self[AppStateKey.self] }
    set { self[AppStateKey.self] = newValue }
  }
}
