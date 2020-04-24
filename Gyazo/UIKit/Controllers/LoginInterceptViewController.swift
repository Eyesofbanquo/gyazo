//
//  LoginInterceptViewController.swift
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

final class LoginInterceptViewController: UIViewController {
  
  // MARK: - Properties -
  
  lazy var oauth: OAuth = OAuth()
    
  var returnFromAuthCancellable: AnyCancellable?
  
  var cancellable: AnyCancellable?
  
  var successfulLogin: Bool = false
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable, message: "Won't be needing the storyboard")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCallbackFromOAuth()
    
    self.view.backgroundColor = .systemPink
    
    authorizeIfNeeded()
  }
  
  private func authorizeIfNeeded() {
    if Secure.keychain["accessToken"] == nil {
      self.cancellable = oauth.authorize(in: self).receive(on: DispatchQueue.main).sink(receiveValue: { success in
        self.successfulLogin = success
      })
    }
  }
  
  private func setupCallbackFromOAuth() {
    self.returnFromAuthCancellable = NotificationCenter.default.publisher(for: .returnFromAuth).sink { notification in
      guard let url = notification.userInfo?["url"] as? URL else { return } // needs error handling
      
      self.oauth.oauth2.handleRedirectURL(url)
    }
  }
}
