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
  
  @State var searchText: String = ""
  
  var body: some View {
    
    
    NavigationView {
      List {
        Section(header: Text("Your images")) {
          ForEach(posts.filter { post in
            if (searchText.isEmpty) {
              return true
            } else {
              return post.metadata?.app?.contains(self.searchText) == true}
          }, id: \.self) { post in
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
            
          .navigationBarTitle(Text("Gyazo"))
          .navigationBarItems(
            leading:
            Button(action: {
              // - Launch Search
            }){
              Image(systemName: "magnifyingglass")}
            ,
            trailing: Button(action: {
              // - Launch Profile Modal
            }){
              Image(systemName: "person.circle")
          })
            .listSeparatorStyleNone()
        }
        
        Section(header: Text("Search")) {
          TextField("Son", text: $searchText)
        }
      }
      
    }
  }
  
  
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Drop] = Drop.stub
  static var previews: some View {
    ContentView(posts: stub)
  }
}
