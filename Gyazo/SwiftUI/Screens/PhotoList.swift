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
  
  var vision: Vision = VisionKey.defaultValue
  @ObservedObject var cloud: Cloud = Cloud()
  
  @ObservedObject var formatter: DateFormat = DateFormat()
  
  @Environment(\.imageCache) var cache: ImageCacheable
  
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
      ForEach(posts, id: \.id) { post in
        photoClippedCell(post: post)
      }
      ForEach(cloudPosts, id: \.id) { cloudPost in
        photoClippedCell(post: cloudPost, type: .cloud)
      }
    }
  }
  
  private func photoClippedCell(post: PhotoListRepresentable, type: PhotoListRepresentableType = .gyazo) -> some View {
    Group {
      AsyncImage(url: post.cacheableImageURL!,
                 title: post.title, placeholder: Image("gilmo-placeholder")
                  .resizable()
                  .aspectRatio(contentMode: .fill),
                 cache: cache,
                 vision: vision,
                 configuration: { $0.resizable() })
        .aspectRatio(contentMode: .fill)
        .frame(height: 300, alignment: .center)
        .frame(minWidth: 0)
        .overlay(backOverlay(post: post, type: type))
        .cornerRadius(10.0)
        .border(Color.red)
        .clipped()
        .padding()
        .shadow(radius: 10)
        .onAppear { onPostAppear(post, type) }
        .contentShape(Rectangle())
        .onTapGesture { onPostTap(post, type) }
        .border(Color.red)
        .clipped()
    }
    
  }
  
  private func onPostAppear(_ post: PhotoListRepresentable, _ type: PhotoListRepresentableType) {
    if type == .gyazo {
      self.cloud.save(post as! Post)
    }
  }
  
  private func onPostTap(_ post: PhotoListRepresentable, _ type: PhotoListRepresentableType) {
    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
      if type == .gyazo {
        self.selectedPost = post as? Post
      } else {
        self.selectedPost = Post(fromCloud: post as! CloudPost)
      }
      self.presentDetailView.toggle()
      
    }
  }
  
  private func PostHeadline(post: PhotoListRepresentable) -> some View {
    Group {
      if post.app.isEmpty && post.title.isEmpty {
        Text("Unknown Source")
          .bold()
          .lineLimit(1)
          .foregroundColor(.white)
          .font(.headline)
      } else if post.app.isEmpty && post.title.isEmpty == false{
        Text(post.title)
          .bold()
          .lineLimit(1)
          .foregroundColor(.white)
          .font(.headline)
      } else if post.app.isEmpty == false && post.title.isEmpty {
        Text(post.app)
          .foregroundColor(.white)
          .font(.headline)
          .bold()
      } else {
        Text(post.title)
          .bold()
          .lineLimit(1)
          .foregroundColor(.white)
          .font(.headline)
      }
    }
  }
  
  private func imageOverlay(post: PhotoListRepresentable, type: PhotoListRepresentableType = .gyazo) -> some View {
    VStack(alignment: .trailing) {
      Spacer()
      Group {
        HStack {
          VStack(alignment: .leading) {
            
            PostHeadline(post: post)
            
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
