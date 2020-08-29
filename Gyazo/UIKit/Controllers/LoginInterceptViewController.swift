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

final class LoginInterceptViewController: UIViewController, ObservableObject {
  
  // MARK: - Properties -
  
  lazy var oauth: OAuth = OAuth()
    
  var returnFromAuthCancellable: AnyCancellable?
  
  var cancellable: AnyCancellable?
  
  var loginSuccessful: Binding<Bool>?
    
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
    
    hostLoginViewComponent()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupCallbackFromOAuth()
    
    self.view.backgroundColor = .systemPink
    
    hostLoginViewComponent()
  }
  
  /// This function will look to authorize the user if they don't currently have an `accessToken` stored inside of the `Keychain`
  func authorizeIfNeeded() {
    if Secure.keychain["accessToken"] == nil {
      self.cancellable = oauth.authorize(in: self).receive(on: DispatchQueue.main).sink(receiveValue: { success in
        if success {
          self.loginSuccessful?.wrappedValue = true
        } else {
          // Present an alert?
        }
      })
    } else {
      self.loginSuccessful?.wrappedValue = true
    }
  }
  
  private func hostLoginViewComponent() {
    let childView = UIHostingController(rootView: LoginView(loginController: self))
    addChild(childView)
    childView.view.frame = view.frame
    view.addSubview(childView.view)
    childView.didMove(toParent: self)
  }
  
  /// This function is the `callback` from the `SceneDelegate` once the user finishes logging in/cancelling from the safari view presented for logging in.
  private func setupCallbackFromOAuth() {
    self.returnFromAuthCancellable = NotificationCenter.default.publisher(for: .returnFromAuth).sink { notification in
      guard let url = notification.userInfo?["url"] as? URL else { return } // needs error handling
      
      self.oauth.oauth2.handleRedirectURL(url)
    }
  }
}
