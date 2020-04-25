//
//  Keychain.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import KeychainAccess

class Secure {
  
  static var keychainService: String = "com.donderapps.gyazo"
  
  static var keychain: Keychain = {
    let keychain = Keychain(service: keychainService)
    return keychain
  }()
}
