//
//  DashboardCell.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import AsyncImage
import Foundation
import SwiftUI

struct DashboardCell<Placeholder: View>: View {
  
  @Environment(\.imageCache) var cache: ImageCacheable
  
  var post: Drop
  
  var placeholder: Placeholder?
  
  @State private var expandView: Bool = false
  
  init(post: Drop, placeholder: Placeholder? = nil) {
    self.post = post
    self.placeholder = placeholder
  }
  
  var body: some View {
    HStack {
      AsyncImage(url: URL(string: post.urlString)!,
                 placeholder: placeholder ?? Text("Loading...") as! Placeholder,
                 cache: self.cache,
                 configuration: { $0.resizable()
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
    .onTapGesture {
      print("Tapped")
    }
    
    
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
  
  static var previews: some View {
    DashboardCell(post: Drop.stub.first!,
                  placeholder: Image("gyazo-image").resizable())
  }
}
