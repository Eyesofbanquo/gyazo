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
    
    List {
      ForEach(posts, id: \.self) { post in
        Group {
          if post.urlString.isEmpty == false {
            AsyncImage(url: URL(string: post.urlString)!, placeholder: Text(post.urlString), cache: self.cache, configuration: { $0.resizable()
            })
              .aspectRatio(contentMode: .fit)
          }
        }
        
        
      }.onReceive(request.request(endpoint: "images")) { posts in
        if let posts = posts {
          self.posts = posts
        }
      }
    }.listSeparatorStyleNone()

  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
