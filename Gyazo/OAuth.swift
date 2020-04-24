//
//  OAuth.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import OAuth2
import UIKit

class OAuth: ObservableObject {
  
  @Published var posts: [Post] = []
  
  let oauth2 = OAuth2CodeGrant(settings: [
    "client_id": API.clientID,
    "client_secret": API.clientSecret,
    "authorize_uri": "https://api.gyazo.com/oauth/authorize",
    "token_uri": "https://api.gyazo.com/oauth/token",
    "redirect_uris": [API.callbackURL],
    "secret_in_body": true,
    "keychain": false
  ] as OAuth2JSON)
  
  var loader: OAuth2DataLoader?
  
  let controller = UIViewController()
  
  func authorize(in scene: UIScene?) -> Future<[Post], Never> {
    guard let scene = scene, let sceneDelegate = (scene.delegate as? SceneDelegate), let window = sceneDelegate.window else {
      return Future<[Post], Never> { seal in
        seal(.success([]))
      }
    }
    
    let url = URL(string: "https://api.gyazo.com/api/images")!
    let request = URLRequest(url: url)
//    print(oauth2)
//    oauth2.authConfig.authorizeEmbedded = true
//    oauth2.authConfig.authorizeContext = window.rootViewController!
    
    self.loader = OAuth2DataLoader(oauth2: oauth2)
    
    return Future<[Post], Never> { seal in
      
      self.loader?.perform(request: request, callback: { response in
        do {
          let data = try response.responseData()
          let posts = try JSONDecoder().decode([Post].self, from: data)
          DispatchQueue.main.async {
            self.posts = posts
            seal(.success(posts))
          }
          
        } catch let error {
          print(error)
        }
      })
    }
  }
}
