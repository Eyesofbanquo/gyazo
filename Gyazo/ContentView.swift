//
//  ContentView.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import SwiftUI
import Combine

struct Post: Hashable, Decodable {
  var title: String
}

struct UIWindowKey: EnvironmentKey {
  static var defaultValue: UIWindow?
  
  typealias Value = UIWindow?
}

extension EnvironmentValues {
  
  var window: UIWindow? {
    get {
      return self[UIWindowKey.self]
    }
    
    set {
      self[UIWindowKey.self] = newValue
    }
  }
}

struct ContentView: View {
  
  @Environment(\.calendar) var keyboard: Calendar
  @State var cancellable: AnyCancellable?
  @State var text: String = ""
  @State var posts: [Post] = []
  @ObservedObject var network: Network = Network()
  @ObservedObject var oauth: OAuth = OAuth()
  @State var presentLogin = false
  
  var body: some View {
//    let scene = UIApplication.shared.connectedScenes.first
//    return List {
//      ForEach(posts, id: \.self) { post in
//        Text("\(post.title)")
//      }.onReceive(oauth.authorize(in: scene)) { p in
//        self.posts = p
//      }
//    }
    VStack {
      Text("Present the login view")
      Button(action: {
        self.presentLogin.toggle()
      }) {
        Text("Press me!")
      }.sheet(isPresented: $presentLogin) {
        LoginIntercept()
      }
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
