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
  
  @Environment(\.imageCache) var cache
  
  @StateObject var request: NetworkRequest<[Drop]> = NetworkRequest<[Drop]>()
  
  @State var posts: [Drop] = []
  
  @Environment(\.vision) var vision: Vision
  
  @EnvironmentObject var userSettings: UserSettings
  
  @State var searchText: String = ""
  
  @State var showingImagePicker = false
  
  @State var selectedImage: UIImage?
  
  @State var pasteboardImage: UIImage?
  
  @State var showingProfile = false
  
  @GestureState var onActiveScroll: CGSize = .zero
  
  @State var uploadImage: UIImage?
  
  @State var expandDashboardCell = false
  
  @State var presentShareController: Bool = false
  
  @Namespace var dashboardCellAnimation
  
  @State var selectedPost: Drop?
  
  var body: some View {
    
    ZStack(alignment: .center) {
      NavigationView {
        ZStack(alignment: .bottomTrailing) {
          VStack {
            ScrollView {
              
              SearchBar(text: $searchText)
              
              VStack(spacing: 8.0) {
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
                      DashboardCell(post: post, placeholder: Text("Loading"), namespace: dashboardCellAnimation)
                        .padding(.horizontal, 8.0)
                        .onTapGesture {
                          withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            self.expandDashboardCell.toggle()
                            self.selectedPost = post
                          }
                        }
                    }
                  }
                }
              }
              .onReceive(request.request(endpoint: .images)) { posts in
                if let posts = posts {
                  self.posts = posts
                }
              }
              
              .navigationBarTitle(Text("Gyazo"))
              .navigationBarItems(
                trailing: Button(action: {
                  self.showingProfile = true
                }){
                  Image(systemName: "person.circle")
                    .foregroundColor(Color(.label))
                    .padding()
                    .font(.title)
                    .contentShape(Rectangle())
                })
              .sheet(isPresented: self.$showingProfile) {
                Profile(presented: $showingProfile)
              }
            }.gesture(DragGesture().updating($onActiveScroll, body: { (value, state, transaction) in
              print("drag")
            })) // Scroll View
          }
          UploadOptions(clipboardImage: $uploadImage, photoLibraryImage: $uploadImage, cameraImage: $uploadImage)
            .offset(x: -16, y: -16)
          
        } // stack
        
        
      } // nav view
      
      if self.uploadImage != nil {
        SelectedImageView(uiimage: uploadImage,
                          imageURL: selectedPost?.urlString ?? "",
                          action: .upload,
                          presentShareController: $presentShareController,
                          presentSelectedImageView: Binding (
                            get: {
                              return self.uploadImage != nil
                            },
                            set: { _ in
                              self.uploadImage = nil
                            })) // inner z-stack
      }
      
      // This should be logic for the detail view
      if expandDashboardCell, let selectedPost = self.selectedPost {
        DashboardDetailView(post: selectedPost,
                            animationNamespace: dashboardCellAnimation,
                            isVisible: $expandDashboardCell)
      }
      
    }// outer z-stack
    .statusBar(hidden: true)
    
  } // body
  
  var pasteboardImageView: Image? {
    guard let image = uploadImage else { return nil }
    
    return Image.init(uiImage: image)
  }
  private func readFromPasteboard() {
    let pasteboard = UIPasteboard.general
    guard let pasteboardImage = pasteboard.image else { return }
    
    self.pasteboardImage = pasteboardImage
  }
  
  var selectedImageURL: URL? {
    guard let urlString = selectedPost?.urlString, let url = URL(string: urlString) else { return nil }
    return url
  }
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Drop] = Drop.stub
  static var previews: some View {
    ContentView(posts: stub)
  }
}
