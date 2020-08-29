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
  var post: Drop
  @State var expanded: Bool = false
  
  // MARK: - Env -
  @Environment(\.imageCache) var cache
  @Namespace var expandAnimationNamespace
  var animationNamespace: Namespace.ID
  
  // MARK: - State -
  var isVisible: Binding<Bool>
  
  @State var formattedDate: String = ""
  @State var showingProfile: Bool = false
  @State var copiedText: Bool = false
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
                .frame(width: g.frame(in: .global).minY > 0 ? g.size.width + g.frame(in: .global).minY : g.size.width,
                       height: g.frame(in: .global).minY > 0 ? UIScreen.main.bounds.height / 2.2 + g.frame(in: .global).minY : UIScreen.main.bounds.height / 2.2)
                .clipped()
                .offset(x: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY / 2 : 0, y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY : 0)
                .matchedGeometryEffect(id: post.id, in: animationNamespace)
            }.frame(height: UIScreen.main.bounds.height / 2.2)
            
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
      
      if self.expanded {
        ZStack(alignment: .center) {
          Color.black
            .opacity(0.05)
            .background(BlurView(style: .extraLight))
          VStack {
            Image("gyazo-image")
              .resizable()
              .aspectRatio(contentMode: .fit)
            Text("\(self.copiedText ? "Copied!" : "Copy to cliboard")")
              .padding()
              .foregroundColor(.white)
              .background(self.copiedText ? Color.green : Color.orange)
              .clipShape(Capsule())
              .onTapGesture {
                withAnimation {
                  self.copiedText = true
                }
                self.copyToPasteboard()
              }
          }
        }
        .edgesIgnoringSafeArea(.all)
        .transition(.scale)
        .onTapGesture {
          self.expanded = false
          self.copiedText = false
        }
      }
    }
    .onReceive(self.dateFormatter.format(fromString: post.createdAt), perform: { date in
      self.formattedDate = date
    })
    .background(Color(.systemBackground))
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    .sheet(isPresented: self.$showingProfile) {
      Profile(presented: $showingProfile)
    }
  }
  
  private var heroImage: Image? {
    #if DEBUG
    return Image("gyazo-image")
    #else
    if let imageURL = post.cacheableImageURL, let cachedImage = self.cache[imageURL] {
      return Image(uiImage: cachedImage)
    }
    return nil
    #endif
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
          withAnimation(Animation.easeInOut(duration: 0.15)) {
            self.expanded = true
          }
        }
      Spacer()
    }
  }
  
  private var navbar: some View {
    ZStack {
      HStack {
        Image(systemName: "xmark.circle.fill")
          .font(.title)
          .foregroundColor(Color.black)
          .onTapGesture {
            withAnimation {
              self.isVisible.wrappedValue = false
            }
          }
        Spacer()
        Image(systemName: "person.circle.fill")
          .font(.title)
          .foregroundColor(Color.black)
          .onTapGesture {
            self.showingProfile = true
          }
      }
      .padding()
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
    DashboardDetailView(post: Drop.stub.first!,
                        expanded: expanded,
                        expandAnimationNamespace: _animation,
                        animationNamespace: imageAnimation,
                        isVisible: isVisible)
  }
}
