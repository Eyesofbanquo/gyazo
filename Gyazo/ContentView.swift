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
  
  @ObservedObject var cloud: Cloud = Cloud()
  
  var body: some View {
    
    ZStack(alignment: .center) {
      NavigationView {
        ZStack(alignment: .bottomTrailing) {
          VStack {
            ScrollView {
              SearchBar(text: $searchText)
              VStack(spacing: 8.0) {
                ForEach(posts.filter { filterSearchResults($0) }, id: \.self) { post in
                  Cell(post)
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
              
              Divider()
              VStack(alignment: .trailing) {
                HStack {
                  Text("Cloud Images")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                  Spacer()
                }
              } // This whole stack may need to be a different color
              .background(Color("gyazo-blue"))
              
            }.gesture(DragGesture().updating($onActiveScroll, body: { (value, state, transaction) in
              print("drag")
            })) // Scroll View
          }
          UploadOptions(clipboardImage: $uploadImage, photoLibraryImage: $uploadImage, cameraImage: $uploadImage)
            .offset(x: -16, y: -16)
          
        } // stack
        
        
      } // nav view
      
      if self.uploadImage != nil {
        UploadImage
      }
      
      // This should be logic for the detail view
      if expandDashboardCell {
        DetailView
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
  
  var UploadImage: some View {
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
  
  var DetailView: some View {
    Group {
      if let selectedPost = self.selectedPost  {
        DashboardDetailView(post: selectedPost,
                            animationNamespace: dashboardCellAnimation,
                            isVisible: $expandDashboardCell)
      } else {
        EmptyView()
      }
    }
   
  }
  
  func filterSearchResults(_ post: Drop) -> Bool {
    if (searchText.isEmpty) {
      return true
    } else {
      let appropriateMLResponses = self.vision.classifications[post.metadata?.title ?? ""]
      let bestResponse = appropriateMLResponses?.first
      let searchTextContainsResponse = (bestResponse?.1.lowercased() ?? "").contains(self.searchText.lowercased())
      return (post.metadata?.app?.contains(self.searchText)) == true || searchTextContainsResponse == true
    }
  }
  
  func Cell(_ post: Drop) -> some View {
    Group {
      if post.urlString.isEmpty == false {
        DashboardCell(post: post, placeholder: Text("Loading"), namespace: dashboardCellAnimation)
          .padding(.horizontal, 8.0)
          .onAppear {
            self.cloud.save(post)
          }
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

struct ContentView_Previews: PreviewProvider {
  static let stub: [Drop] = Drop.stub
  static var previews: some View {
    ContentView(posts: stub)
  }
}
