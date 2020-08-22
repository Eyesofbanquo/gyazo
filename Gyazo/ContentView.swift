//
//  ContentView.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import SwiftUI
import Combine
import AsyncImage

struct ContentView: View {
  
  @ObservedObject var request: NetworkRequest<[Drop]> = NetworkRequest<[Drop]>()
  
  @State var posts: [Drop] = []
  
  @Environment(\.imageCache) var cache: ImageCacheable
  
  var body: some View {
    
    NavigationView {
      List {
        ForEach(posts, id: \.self) { post in
          Group {
            if post.urlString.isEmpty == false {
              DashboardCell(post: post, placeholder: Text("Loading"))
            }
          }
        }.onReceive(request.request(endpoint: "images")) { posts in
          if let posts = posts {
            self.posts = posts
          }
        }
      }
      .navigationBarTitle(Text("unGyazo"))
      .listSeparatorStyleNone()
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Drop] = Drop.stub
  static var previews: some View {
    ContentView(posts: stub)
  }
}
