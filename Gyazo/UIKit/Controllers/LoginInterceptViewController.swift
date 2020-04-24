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

final class LoginInterceptViewController: UIViewController {
  
  // MARK: - Properties -
  
  lazy var oauth: OAuth = OAuth()
  
  var passthrough: PassthroughSubject<[Post], Never>?
  
  var returnFromAuthCancellable: AnyCancellable?
  
  var cancellable: AnyCancellable?
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable, message: "Won't be needing the storyboard")
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.returnFromAuthCancellable = NotificationCenter.default.publisher(for: .returnFromAuth).sink { notification in
      guard let url = notification.userInfo?["url"] as? URL, let components = URLComponents(string: url.absoluteString), let code = components.queryItems?.first, let codeIndex = url.absoluteString.firstIndex(of: "?")else { return } // needs error handling
      
      let urlStringWithoutCode = String(url.absoluteString[..<codeIndex])
            
      print(code)
      
      self.oauth.oauth2.handleRedirectURL(url)
    }
    
    self.view.backgroundColor = .systemPink
    
    passthrough = PassthroughSubject<[Post], Never>()
    
    
    self.cancellable = oauth.authorize(in: self).receive(on: DispatchQueue.main).sink(receiveValue: { p in
      print(p)
    })
    
  }
}
