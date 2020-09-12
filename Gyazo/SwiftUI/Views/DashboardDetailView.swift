//
//  DashboardDetailView.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/28/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct DashboardDetailView: View {
  var post: Post
  @State var expanded: Bool = false
  
  // MARK: - Env -
  @Environment(\.imageCache) var cache
  var animationNamespace: Namespace.ID
  
  // MARK: - State -
  var isVisible: Binding<Bool>
  
  @State var formattedDate: String = ""
  @State var showingProfile: Bool = false
  @State var copiedText: Bool = false
  @State var shareController: Bool = false
  @ObservedObject var dateFormatter: DateFormat = DateFormat()
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      ScrollView {
        VStack {
          ZStack(alignment: .bottomTrailing) {
            
            GeometryReader { g in
              heroImage?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .layoutPriority(1)
                .frame(width: g.frame(in: .global).minY > 0 ? g.size.width + g.frame(in: .global).minY : g.size.width,
                       height: g.frame(in: .global).minY > 0 ? UIScreen.main.bounds.height / 2.2 + g.frame(in: .global).minY : UIScreen.main.bounds.height / 2.2)
                .clipped()
                .offset(x: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY / 2 : 0, y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY : 0)
                .matchedGeometryEffect(id: post.id, in: animationNamespace)
            }
            .frame(height: UIScreen.main.bounds.height / 2.2)
            
            tapToExpandControl
          }
          
          
          VStack(alignment: .leading) {
            Text(formattedDate)
              .foregroundColor(Color(.label))
            if let metadata = post.metadata {
              if let app = metadata.app {
                Text(app)
                  .foregroundColor(Color(.label))
              }
              
              if let description = metadata.description {
                TextEditor(text:
                            .constant("Type a description"))
                  .border(Color.black.opacity(0.67))
                  .foregroundColor(Color(.label))
              }
              
            }
          }
          .padding(.horizontal)
          
        }
        
      }
      navbar
      
      if self.expanded, let imageURL = post.cacheableImageURL {
        SelectedImageView(uiimage: cache[imageURL],
                          imageURL: post.urlString,
                          action: .clipboard,
                          presentShareController: $shareController,
                          presentSelectedImageView: $expanded
                          )
        .transition(.popInFade(scaleBy: 0.5))
        .zIndex(1)
      }
    }
    .onReceive(self.dateFormatter.format(fromString: post.createdAt), perform: { date in
      self.formattedDate = date
    })
    .background(Color(.systemBackground))
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    
  }
  
  private var heroImage: Image? {
    if let imageURL = post.cacheableImageURL, let cachedImage = self.cache[imageURL] {
      return Image(uiImage: cachedImage)
    }
    return nil
  }
  
  private var tapToExpandControl: some View {
    HStack {
      Spacer()
      Text("Tap to enlarge")
        .font(.headline)
        .padding()
        .background(Color(.systemFill))
        .foregroundColor(.white)
        .clipShape(Capsule())
        .contentShape(Capsule())
        .padding(.bottom, 8.0)
        .onTapGesture {
          withAnimation(Animation.easeOut(duration: 5)) {
            self.expanded = true
          }
        }
      Spacer()
    }
  }
  
  private var navbar: some View {
      HStack {
        Image(systemName: "xmark.circle.fill")
          .font(.title)
          .foregroundColor(Color.white)
          .background(Color.black)
          .clipShape(Circle())
          .onTapGesture {
            withAnimation {
              self.isVisible.wrappedValue = false
            }
          }
          .padding(.top, 8.0)
          .padding(.leading, 16.0)
        Spacer()
        Image(systemName: "person.circle.fill")
          .font(.title)
          .foregroundColor(Color.white)
          .background(Color.black)
          .clipShape(Circle())
          .onTapGesture {
            self.showingProfile = true
          }
          .sheet(isPresented: self.$showingProfile) {
            Profile(presented: $showingProfile)
          }
          .padding(.top, 8.0)
          .padding(.trailing, 16.0)
      }
  }
  
  private func copyToPasteboard() {
    let pasteboard = UIPasteboard.general
    
    if let imageURL = post.cacheableImageURL,
       let cachedImage = self.cache[imageURL] {
      pasteboard.image = cachedImage
    }
  }
}

struct DashboardDetailView_Previews: PreviewProvider {
  @Namespace static var imageAnimation
  static var visible: Bool = true
  static var isVisible = Binding<Bool>(
    get: {
      visible
    }, set: {
      visible = $0
    })
  @Namespace static var animation
  @State static  var expanded: Bool = false
  static var previews: some View {
    DashboardDetailView(post: Post.stub.first!,
                        expanded: expanded,
                        animationNamespace: imageAnimation,
                        isVisible: isVisible)
  }
}