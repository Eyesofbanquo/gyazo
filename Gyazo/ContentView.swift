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
  
  @Environment(\.vision) var vision: Vision
  
  @State var searchText: String = ""
  
  var body: some View {
    
    
    NavigationView {
      VStack {
        ScrollView {
          //          GeometryReader { geo in
          //            Image("gyazo-image")
          //              .resizable()
          //              .aspectRatio(contentMode: .fill)
          //              .offset(y: geo.frame(in: .global).minY > 0 ? -geo.frame(in: .global).minY : 0)
          //              .frame(width: UIScreen.main.bounds.width,
          //                     height: geo.frame(in: .global).minY > 0 ? geo.frame(in: .global).minY + 300 : 300)
          //          }
          //          .frame(height: 300)
          
          SearchBar(text: $searchText)
          ForEach(posts.filter { post in
            if (searchText.isEmpty) {
              return true
            } else {
              let appropriateMLResponses = self.vision.classifications[post.metadata?.title ?? ""]
              let bestResponse = appropriateMLResponses?.first
              let searchTextContainsResponse = (bestResponse?.1.lowercased() ?? "").contains(self.searchText.lowercased())
              return (post.metadata?.app?.contains(self.searchText)) == true || searchTextContainsResponse == true
            }
          }, id: \.self) { post in
            Group {
              if post.urlString.isEmpty == false {
                DashboardCell(post: post, placeholder: Text("Loading"))
                  .padding(.horizontal, 8.0)
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
