//
//  Gyazo.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

enum Gyazo {
  enum Endpoint {
    case images
    case user
    
    var path: String {
      switch self {
        case .images: return "images"
        case .user: return "users/me"
      }
    }
  }
}
