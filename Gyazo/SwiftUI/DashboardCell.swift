//
//  DashboardCell.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct DashboardCell<Placeholder: View>: View {
  
  @Environment(\.imageCache) var cache: ImageCacheable
  
  @Environment(\.vision) var vision: Vision
  
  var dashboardCell: Namespace.ID
    
  var post: Post
  
  var placeholder: Placeholder?
  
  @State private var expandView: Bool = false
  
  init(post: Post,
       placeholder: Placeholder? = nil,
       namespace: Namespace.ID) {
    self.post = post
    self.placeholder = placeholder
    self.dashboardCell = namespace
  }
  
  init(cloud: CloudPost,
       placeholder: Placeholder? = nil,
       namespace: Namespace.ID) {
    self.post = Post(fromCloud: cloud)!
    self.placeholder = placeholder
    self.dashboardCell = namespace
  }
  
  var body: some View {
    HStack {
      AsyncImage(url: URL(string: post.urlString)!,
                 title: post.metadata?.title,
                 placeholder: placeholder ?? Text("Loading...") as! Placeholder,
                 cache: self.cache,
                 vision: self.vision,
                 configuration: { image in
                  // This is where you'll hit the model
                  image.resizable()
      })
        .frame(width: 100, height: 100)
        .aspectRatio(contentMode: .fit)
        .cornerRadius(20)
      
      VStack(alignment: .leading) {
        titleText
        imageSourceText
        Spacer()
      }
      .frame(maxHeight: 100)
      .padding(.top, 8.0)
      
      Spacer()
    }
    .contentShape(Rectangle())
    .matchedGeometryEffect(id: post.id, in: dashboardCell)
    
    
  }
  
  private var titleText: some View {
    if let title = post.metadata?.title {
      return Text(title)
        .font(.headline)
    } else {
      return Text("No title")
        .font(.headline)
        .italic()
    }
  }
  
  private var imageSourceText: some View {
    if let sourceApp = post.metadata?.app {
      return Text(sourceApp)
        .font(.caption)
    } else {
      return Text("Unknown")
        .font(.caption)
        .italic()
    }
  }
}

struct DashboardCell_Previews: PreviewProvider {
  
  @Namespace static var namespace
  
  static var previews: some View {
    DashboardCell(post: Post.stub.first!,
                  placeholder: Image("gyazo-image").resizable(), namespace: namespace)
  }
}
