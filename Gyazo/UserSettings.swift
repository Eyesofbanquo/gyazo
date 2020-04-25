//
//  UserSettings.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
  @Published var isLoggedIn = {
    return Secure.keychain["access_token"] != nil
  }()
}
