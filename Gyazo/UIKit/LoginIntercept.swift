//
//  LoginIntercept.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct LoginIntercept: UIViewControllerRepresentable {
  
  @Binding var loginSuccessful: Bool
  
  typealias UIViewControllerType = LoginInterceptViewController
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<LoginIntercept>) -> LoginInterceptViewController {
    let controller = LoginInterceptViewController()
    controller.loginSuccessful = $loginSuccessful
    return controller
  }
  
  func updateUIViewController(_ uiViewController: LoginInterceptViewController, context: UIViewControllerRepresentableContext<LoginIntercept>) {
    
  }
  
}
