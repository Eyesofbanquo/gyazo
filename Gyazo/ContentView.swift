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
  
  @ObservedObject var vm: ContentViewModel = ContentViewModel()
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
            PhotoList(posts: $posts,
                      cloudPosts: $cloudPosts,
                      presentDetailView: $state.presentDashboardCell,
                      selectedPost: $state.selectedPost,
                      detailViewNamespace: detailViewAnimation)
          } // v- stack
          
          UploadOptions(clipboardImage: $state.uploadImage, photoLibraryImage: $state.uploadImage, cameraImage: $state.uploadImage)
            .offset(x: -16, y: -16)
          
        }
        .navigationBarTitle(Text("Gyazo"))
        .navigationBarItems(
          trailing: ProfileNavigationItem)
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
    .onAppear(perform: vm.retrieveAllPosts)
    .onReceive(vm.$posts, perform: { posts in
      print(posts.count)
      // Remember - it returns 20 posts no matter what. 
      self.posts = posts
    })
    .onReceive(vm.$cloudPosts, perform: { cloudPosts in
      self.cloudPosts = cloudPosts
    })
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { output in
      self.vm.retrieveAllPosts()
    })
    
  } // body
  
  
}

// MARK: - Views -

extension ContentView {
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
  
  var ProfileNavigationItem: some View {
    Button(action: {
      self.state.showingProfile = true
    }){
      Image(systemName: "person.circle")
        .foregroundColor(Color(.label))
        .navbarIconify()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static let stub: [Post] = Post.stub
  static var previews: some View {
    ContentView(posts: Post.stub)
  }
}
