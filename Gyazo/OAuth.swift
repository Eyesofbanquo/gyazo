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
import SwiftUI

struct AuthResponse: Decodable {
  var accessToken: String
  var tokenType: String
  var scope: String
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case scope
  }
}

class OAuth: ObservableObject {
  
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
  
  func authorize(in controller: UIViewController?) -> Future<Bool, Never> {
    guard let controller = controller else {
      return Future<Bool, Never> { seal in
        seal(.success(false))
      }
    }
    
    oauth2.authConfig.authorizeEmbedded = true
    oauth2.authConfig.authorizeContext = controller
    
    self.loader = OAuth2DataLoader(oauth2: oauth2)
    
    return Future<Bool, Never> { seal in
      
      DispatchQueue.main.async {
        self.oauth2.authorize() { params, error in
          if let params = params, let accessToken = params["access_token"] as? String {
            Secure.keychain["access_token"] = accessToken
            print(params)
            seal(.success(true))
          }
        }
      }
    }
  }
  
  func logout() {
    oauth2.forgetClient()
    oauth2.forgetTokens()
    Secure.keychain["access_token"] = nil
    let storage = HTTPCookieStorage.shared
    storage.cookies?.forEach() { storage.deleteCookie($0) }
  }
}

struct OAuthKey: EnvironmentKey {
  static let defaultValue: OAuth = OAuth()
}

extension EnvironmentValues {
  var oauthKey: OAuth {
    get { self[OAuthKey.self] }
    set { self[OAuthKey.self] = newValue }
  }
}

