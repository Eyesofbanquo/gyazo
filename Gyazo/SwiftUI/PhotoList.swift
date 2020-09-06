//
//  PhotoList.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/5/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct PhotoList: View {
  
  enum Strings: String {
    case gyazoHeader = "Gyazo"
    case cloudHeader = "Cloud"
  }
  
  @Binding var posts: [Post]
  @Binding var cloudPosts: [CloudPost]
  @Binding var presentDetailView: Bool
  @Binding var selectedPost: Post?
  
  var cache: ImageCacheable = ImageCacheKey.defaultValue
  var vision: Vision = VisionKey.defaultValue
  @ObservedObject var cloud: Cloud = Cloud()
  
  @ObservedObject var formatter: DateFormat = DateFormat()
  
  var detailViewNamespace: Namespace.ID
  
  var body: some View {
    content
  }
  
  private var content: some View {
    photoListContentView
  }
  
  private var photoListContentView: some View {
    
    ScrollView {
      photoList
    }
  }
  
  private var photoListHeader: some View {
    HStack {
      Text("Header")
        .font(.headline)
        .padding(.leading)
      Spacer()
    }
  }
  
  private var photoList: some View {
    return LazyVStack {
      ForEach(posts, id: \.self) { post in
        photoClippedCell(post: post)
      }
      ForEach(cloudPosts, id: \.self) { cloudPost in
        photoClippedCell(post: cloudPost, type: .cloud)
      }
    }
  }
  
  private func photoClippedCell(post: PhotoListRepresentable, type: PhotoListRepresentableType = .gyazo) -> some View {
    Group {
      AsyncImage(url: post.cacheableImageURL!, title: post.title, placeholder: Text("Loading"), cache: cache, vision: vision, configuration: { $0.resizable() })
        .aspectRatio(contentMode: .fill)
        .frame(height: 300, alignment: .center)
        .frame(minWidth: 0)
        .overlay(backOverlay(post: post, type: type))
        .cornerRadius(10.0)
        .border(Color.red)
        .clipped()
        .padding()
        .shadow(radius: 10)
        .onAppear {
          if type == .gyazo {
            self.cloud.save(post as! Post)
          }
        }
        .onTapGesture {
          withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
            self.presentDetailView.toggle()
            if type == .gyazo {
              self.selectedPost = post as? Post
            } else {
              self.selectedPost = Post(fromCloud: post as! CloudPost)
            }
          }
        }
        
    }
    .matchedGeometryEffect(id: post.id, in: detailViewNamespace)
    .border(Color.red)
    .clipped()
  }
  
  private func imageOverlay(post: PhotoListRepresentable, type: PhotoListRepresentableType = .gyazo) -> some View {
    VStack(alignment: .trailing) {
      Spacer()
      Group {
        HStack {
          VStack(alignment: .leading) {
            Text(post.app)
              .foregroundColor(.white)
              .font(.headline)
              .bold()
            Text(post.date)
              .foregroundColor(.white)
              .font(.caption)
              .bold()
          }
          Spacer()
          if type == .cloud {
            Image(systemName: "cloud.fill")
              .font(.callout)
              .foregroundColor(.white)
          }
        }
        .padding(.horizontal, 16.0)
      }
    }
    .padding(.top)
  }
  
  private func backOverlay(post: PhotoListRepresentable, type: PhotoListRepresentableType = .gyazo) -> some View {
    VStack(alignment: .trailing) {
      Rectangle()
        .background(Color.black)
        .frame(height: 44)
        .opacity(1)
        .blur(radius: 64)
        .overlay(imageOverlay(post: post, type: type))
      Spacer()
    }
  }
}
//
//struct PhotoList_Previews: PreviewProvider {
//  static var posts: [Post] = Post.stub
//  static var postsBinding = Binding (
//    get: {
//      return posts
//    },
//    set: {
//      posts = $0
//    })
//
//  static var cloudPostsBinding = Binding<[CloudPost]> (
//    get: {
//      return []
//    }, set: { _ in
//    })
//
//  static var previews: some View {
//    PhotoList(posts: postsBinding, cloudPosts: cloudPostsBinding)
//  }
//}
