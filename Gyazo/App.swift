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
}

var oauth: OAuth = OAuth()

var userSettings: UserSettings = UserSettings()

var secure: Secure = Secure()

@main
struct TestApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  @State var loginSuccessful: Bool = false
  
  var body: some Scene {
    WindowGroup {
      Group {
        if Secure.keychain["access_token"] == nil && loginSuccessful == false { LoginIntercept(loginSuccessful: $loginSuccessful).environmentObject(userSettings)
        } else {
          ContentView().environmentObject(userSettings)
        }
      }
      .onOpenURL { url in
        NotificationCenter.default.post(name: .returnFromAuth, object: nil, userInfo: ["url": url])
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    print("Your code here")
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    NotificationCenter.default.post(name: .returnFromAuth, object: nil, userInfo: ["url": url])
    
    return true
  }
}
