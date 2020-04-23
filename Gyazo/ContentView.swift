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

struct ContentView: View {
  
  @State var cancellable: AnyCancellable?
  @State var text: String = ""
  @State var posts: [Post] = []
  @ObservedObject var network: Network = Network()
  
  var body: some View {
    
//    network.request { publisher in
//      publisher.assign(to: \.posts, on: self)
//    }
      
    return List {
      ForEach(posts, id: \.self) { post in
        Text("\(post.title)")
      }.onReceive(network.requestPublisher()) { p in
        self.posts = p
      }
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
