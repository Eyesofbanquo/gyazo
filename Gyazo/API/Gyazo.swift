//
//  Gyazo.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

enum GyazoAPI {
  enum Endpoint {
    case images
    case user
    case upload
    
    var path: String {
      switch self {
        case .images: return "images"
        case .user: return "users/me"
        case .upload: return "upload"
      }
    }
  }
}
