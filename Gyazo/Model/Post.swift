//
//  Drop.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation

enum PhotoListRepresentableType {
  case gyazo
  case cloud
}

protocol PhotoListRepresentable {
  var title: String { get }
  var date: String { get }
  var id: String { get }
  var app: String { get }
  var cacheableImageURL: URL? { get }
}

var formatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "MMM dd, yyyy HH:mm"
  
  return formatter
}()

struct DropMetadata: Hashable, Decodable {
  var app: String?
  var title: String?
  var urlString: String?
  var description: String?
  
  enum CodingKeys: String, CodingKey {
    case app, title
    case urlString = "url"
    case description = "desc"
  }
}

/// This type represents the `gyazo` resource type. Can be either an image or a gif.
struct Post: Hashable, Decodable, PhotoListRepresentable {
  
  var id: String
  var thumbURLString: String
  var urlString: String
  var type: String
  var metadata: DropMetadata?
  var createdAt: String
  
  var date: String {
    
    let localISOFormatter = ISO8601DateFormatter()
    localISOFormatter.timeZone = TimeZone.current
    guard let dateObject = localISOFormatter.date(from: createdAt) else {
      return ""
    }
    
    let newDateString = formatter.string(from: dateObject)
    
    return newDateString
  }
  
  var app: String {
    return metadata?.app ?? ""
  }
  
  var title: String {
    return metadata?.title ?? ""
  }
  
}

extension Post {
  
  init?(fromCloud cloud: CloudPost) {
    self.id = (cloud.id + "cloud")
    self.urlString = cloud.imageURL
    self.type = ""
    self.metadata = DropMetadata(app: cloud.app, title: cloud.title, urlString: cloud.imageURL, description: cloud.description)
    self.createdAt = ""
    self.thumbURLString = ""
  }
  
  enum CodingKeys: String, CodingKey {
    case type, metadata
    case id = "image_id"
    case thumbURLString = "thumb_url"
    case urlString = "url"
    case createdAt = "created_at"
  }
}

extension Post {
  static var stub: [Post] {
    [
      Post(id: "0", thumbURLString: "", urlString: "https://preview.redd.it/bk2uehh90gi51.jpg?width=576&auto=webp&s=5ebed25519aaf180f83cecca1ae66ba60705eca6", type: "image", createdAt: ""),
      Post(id: "1", thumbURLString: "", urlString: "https://preview.redd.it/2b8aq67yzfi51.jpg?width=576&auto=webp&s=5a74130304fbdfeb5bea3f5faff7acc00f39ef81", type: "image", createdAt: ""),
      Post(id: "2", thumbURLString: "", urlString: "https://preview.redd.it/lhxuul5jksh51.jpg?width=578&auto=webp&s=59595316a6ea09d0f6cd680dfea0330ad097592f", type: "image", createdAt: ""),
      Post(id: "0", thumbURLString: "", urlString: "https://preview.redd.it/bk2uehh90gi51.jpg?width=576&auto=webp&s=5ebed25519aaf180f83cecca1ae66ba60705eca6", type: "image", createdAt: ""),
      Post(id: "1", thumbURLString: "", urlString: "https://preview.redd.it/2b8aq67yzfi51.jpg?width=576&auto=webp&s=5a74130304fbdfeb5bea3f5faff7acc00f39ef81", type: "image", createdAt: ""),
      Post(id: "2", thumbURLString: "", urlString: "https://preview.redd.it/lhxuul5jksh51.jpg?width=578&auto=webp&s=59595316a6ea09d0f6cd680dfea0330ad097592f", type: "image", createdAt: "")
    ]
  }
}

extension Post {
  var cacheableImageURL: URL? {
    URL(string: self.urlString)
  }
}
