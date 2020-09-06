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

struct TableView: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .listRowInsets(EdgeInsets())
      .background(Color(.systemBackground))
  }
}

struct ContentView: View {
  
  @StateObject var vm: ContentViewModel = ContentViewModel()
  @State var state: ContentViewState = ContentViewState()
  @State var posts: [Post] = []
  @State var cloudPosts: [CloudPost] = []
  
  @Namespace var detailViewAnimation
  
  @ObservedObject var cloud: Cloud = Cloud()
  
  var body: some View {
    
    ZStack(alignment: .center) {
      NavigationView {
        ZStack(alignment: .bottomTrailing) {
          VStack {
            SearchBar(text: $state.searchText)
            ScrollView {
              Section(header: Text("Gyazo Photos")) {
                LazyVStack(spacing: 8.0) {
                  ForEach(posts.filter { vm.filterSearchResults($0, forText: state.searchText) }, id: \.self) { post in
                    Cell(post)
                  }
                }
                .modifier(TableView())
                
              }
              Section(header: Text("iCloud Photos")) {
                LazyVStack(spacing: 8.0) {
                  ForEach(cloudPosts, id: \.self) { cloud in
                    CloudCell(cloud)
                  }
                }.modifier(TableView())
              }
            }.listStyle(PlainListStyle())
            .edgesIgnoringSafeArea(.all)// Scroll View
          } // v- stack
          
          UploadOptions(clipboardImage: $state.uploadImage, photoLibraryImage: $state.uploadImage, cameraImage: $state.uploadImage)
            .offset(x: -16, y: -16)
          
        }
        .navigationBarTitle(Text("Gyazo"))
        .navigationBarItems(
          trailing: Button(action: {
            self.state.showingProfile = true
          }){
            Image(systemName: "person.circle")
              .foregroundColor(Color(.label))
              .padding()
              .font(.title)
              .contentShape(Rectangle())
          })
        .sheet(isPresented: self.$state.showingProfile) {
          Profile(presented: $state.showingProfile)
        }//z- stack
        
        
      } // nav view
      
      if state.uploadImage != nil {
        UploadImage
      }
      
      // This should be logic for the detail view
      if state.presentDashboardCell {
        DetailView
      }
      
    }// outer z-stack
    
    .statusBar(hidden: true)
    .onAppear(perform: vm.retrievePosts)
    .onAppear(perform: vm.retrieveCloudPosts)
    .onReceive(vm.$posts, perform: { posts in
      self.posts = posts
    })
    .onReceive(vm.$cloudPosts, perform: { cloudPosts in
      self.cloudPosts = cloudPosts
    })
    
  } // body
  
  var pasteboardImageView: Image? {
    guard let image = state.uploadImage else { return nil }
    
    return Image.init(uiImage: image)
  }
  
  var selectedImageURL: URL? {
    guard let urlString = state.selectedPost?.urlString, let url = URL(string: urlString) else { return nil }
    return url
  }
  
  var UploadImage: some View {
    SelectedImageView(uiimage: state.uploadImage,
                      imageURL: state.selectedPost?.urlString ?? "",
                      action: .upload,
                      presentShareController: $state.presentShareController,
                      presentSelectedImageView: Binding (
                        get: {
                          return self.state.uploadImage != nil
                        },
                        set: { _ in
                          self.state.uploadImage = nil
                        })) // inner z-stack
  }
  
  var DetailView: some View {
    Group {
      if let selectedPost = self.state.selectedPost  {
        DashboardDetailView(post: selectedPost,
                            animationNamespace: detailViewAnimation,
                            isVisible: $state.presentDashboardCell)
      } else {
        EmptyView()
      }
    }
    
  }
  
  func Cell(_ post: Post) -> some View {
    Group {
      if post.urlString.isEmpty == false {
        DashboardCell(post: post, placeholder: Text("Loading"), namespace: detailViewAnimation)
          .padding(.horizontal, 8.0)
          .onAppear {
            self.cloud.save(post)
          }
          .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
              self.state.presentDashboardCell.toggle()
              self.state.selectedPost = post
            }
          }
      }
    }
  }
  
  func CloudCell(_ post: CloudPost) -> some View {
    DashboardCell(cloud: post, placeholder: Text("Loading"), namespace: detailViewAnimation)
      .padding(.horizontal, 8.0)
      .onTapGesture {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
          self.state.presentDashboardCell.toggle()
          self.state.selectedPost = Post(fromCloud: post)
        }
      }
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Post] = Post.stub
  static var previews: some View {
    ContentView()
  }
}
