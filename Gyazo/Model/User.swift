//
//  User.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

struct UserContainer: Decodable {
  var user: User
}

struct User: Decodable {
  
  var email: String?
  var name: String?
  var profileImage: String?
  var id: String
  
  enum CodingKeys: String, CodingKey {
    case email, name
    case profileImage = "profile_image"
    case id = "uid"
  }
}
