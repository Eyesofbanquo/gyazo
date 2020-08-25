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
    
  @Environment(\.vision) var vision: Vision
  
  @EnvironmentObject var userSettings: UserSettings
  
  @State var searchText: String = ""
  
  @State var showingImagePicker = false
  
  @State var selectedImage: UIImage?
  
  @State var pasteboardImage: UIImage?
  
  var body: some View {
    
    ZStack(alignment: .center) {
      NavigationView {
        ZStack(alignment: .bottomTrailing) {
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
                trailing: Button(action: {
                  // - Launch Profile Modal
                  self.readFromPasteboard()
                }){
                  Image(systemName: "person.circle").font(.headline)
              })
            }
          }
          Image(systemName: "camera")
            .padding()
            .background(Circle().foregroundColor(Color(.systemTeal)))
            .offset(x: -16, y: -16)
            .shadow(color: Color(.systemTeal), radius: 8.0, x: 0, y: 0)
            .onTapGesture {
              self.showingImagePicker = true
          }
        } // stack
          .sheet(isPresented: $showingImagePicker, content: {
            ImagePicker(image: self.$selectedImage)
          })
        
      } // nav view
      
      if self.pasteboardImage != nil {
        ZStack(alignment: .center) {
          //        Color.red
          VStack {
            //          Image("gyazo-image")
            pasteboardImageView?
              .resizable()
              .padding(.horizontal)
              .aspectRatio(contentMode: .fit)
              .onTapGesture {
                self.pasteboardImage = nil
            }
            Text("Image classification")
          }
        } // inner z-stack
      }

    }// outer z-stack
    
  } // body
  
  var pasteboardImageView: Image? {
    guard let image = pasteboardImage else { return nil }
    
    return Image.init(uiImage: image)
  }
  private func readFromPasteboard() {
    let pasteboard = UIPasteboard.general
    guard let pasteboardImage = pasteboard.image else { return }
    
    print(userSettings.accessToken)
    
    self.pasteboardImage = pasteboardImage
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Drop] = Drop.stub
  static var previews: some View {
    ContentView(posts: stub)
  }
}
