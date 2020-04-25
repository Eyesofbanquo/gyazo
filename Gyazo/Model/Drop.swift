//
//  Drop.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

/// This type represents the `gyazo` resource type. Can be either an image or a gif.
struct Drop: Hashable, Decodable {
  var id: String
  var thumbURLString: String
  var urlString: String
  var type: String
}

extension Drop {
  
  enum CodingKeys: String, CodingKey {
    case type
    case id = "image_id"
    case thumbURLString = "thumb_url"
    case urlString = "url"
  }
}
