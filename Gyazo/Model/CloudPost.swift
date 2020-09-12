//
//  CloudPost.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/12/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

struct CloudPost: Hashable, Identifiable {
  var title: String
  var id: String
  var imageURL: String
  var description: String
  var app: String
  var date: String
}

extension CloudPost: PhotoListRepresentable {
  
  var cacheableImageURL: URL? {
    return URL(string: imageURL)
  }
}
