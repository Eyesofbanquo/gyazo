//
//  App.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

extension Notification.Name {
  static var returnFromAuth: Notification.Name = Notification.Name("returnFromAuth")
  static var loggedOut: Notification.Name = Notification.Name("loggedOut")
}

var oauth: OAuth = OAuth()

var userSettings: UserSettings = UserSettings()

var secure: Secure = Secure()


@main
struct TestApp: App {
  @State var loginSuccessful: Bool = false
  
  @Environment(\.presentationMode) var presentationMode
  
  var body: some Scene {
    WindowGroup {
      VStack {
        if Secure.keychain["access_token"] == nil && loginSuccessful == false {
          LoginIntercept(loginSuccessful: $loginSuccessful).environmentObject(userSettings)
        } else {
          ContentView().environmentObject(userSettings)
        }
      }
      .onOpenURL { url in
        NotificationCenter.default.post(name: .returnFromAuth, object: nil, userInfo: ["url": url])
      }
      .onReceive(NotificationCenter.default.publisher(for: .loggedOut), perform: { _ in
        self.loginSuccessful = false
      })
    }
  }
}
