//
//  LoginView.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct LoginView: View {
  
  @ObservedObject var loginController: LoginInterceptViewController
  
  var body: some View {
    return VStack {
      Text("Welcome to Dropp")
      Button("Login Here") {
        self.loginController.authorizeIfNeeded()
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  
  static var previews: some View {
    return LoginView(loginController: LoginInterceptViewController())
  }
}
