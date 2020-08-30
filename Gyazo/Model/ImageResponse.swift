//
//  ImageResponse.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/30/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

struct ImageResponse: Codable {
  var image_id: String
  var permalink_url: String
  var thumb_url: String
  var url: String
  var type: String
}
