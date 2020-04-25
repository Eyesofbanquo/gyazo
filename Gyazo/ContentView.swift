//
//  ContentView.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
  
  @ObservedObject var request: NetworkRequest<[Drop]> = NetworkRequest<[Drop]>()
  
  @State var posts: [Drop] = []
  
  var body: some View {
    
    List {
      ForEach(posts, id: \.self) { post in
        Text(post.urlString)
      }.onReceive(request.request(endpoint: "images")) { posts in
        if let posts = posts {
          self.posts = posts
        }
      }
    }

  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
