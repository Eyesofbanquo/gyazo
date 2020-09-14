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
  
  // MARK: - Env -
  @Environment(\.imageCache) var cache
  
  // MARK: - State -
  var isVisible: Binding<Bool>
  
  var heroAnimationID: Namespace.ID
  
  @ObservedObject var vm: DashboardDetailVM
  @State var state: DashboardDetailViewState = DashboardDetailViewState()
  
  @ObservedObject var dateFormatter: DateFormat = DateFormat()
  
  init(post: Post, heroAnimationNamespace: Namespace.ID, isVisible: Binding<Bool>) {
    self.post = post
    self.vm = DashboardDetailVM(post: post)
    self.heroAnimationID = heroAnimationNamespace
    self.isVisible = isVisible
    
    self.vm.formatDate()
  }
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      ScrollView {
        VStack {
          ZStack(alignment: .bottomTrailing) {
            GeometryReader { g in
              HeroImage?
                .asStretchyHeader(in: g)
                .layoutPriority(1)
                .matchedGeometryEffect(id: post.id,
                                       in: heroAnimationID)
            }
            .frame(height: UIScreen.main.bounds.height / 2.2)
            TapToExpandControl
          }
        }
        DetailBody
          .frame(maxWidth: .infinity)
          .padding(.horizontal)
      }
      
      Navbar
      
      SelectedImage
        .zIndex(1)
    }
    .sheet(isPresented: $state.showingProfile) {
      Profile(presented: $state.showingProfile)
    }
    .onReceive(self.vm.$postDate, perform: { date in
      self.state.formattedDate = date
    })
    .background(Color(.systemBackground))
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    
    
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
                        heroAnimationNamespace: imageAnimation,
                        isVisible: isVisible)
  }
}

// MARK: - Views -

extension DashboardDetailView {
  
  private var HeroImage: Image? {
    if let imageURL = post.cacheableImageURL, let cachedImage = self.cache[imageURL] {
      return Image(uiImage: cachedImage)
    }
    return nil
  }
  
  private var SelectedImage: some View {
    Group {
      if state.expanded, let imageURL = post.cacheableImageURL {
        SelectedImageView(uiimage: cache[imageURL],
                          imageURL: post.urlString,
                          action: .clipboard,
                          presentShareController: $state.shareController,
                          presentSelectedImageView: $state.expanded
        )
        .transition(.popInFade(scaleBy: 0.5))
      }
    }
  }
  
  private var TapToExpandControl: some View {
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
          withAnimation(Animation.easeOut(duration: 0.15)) {
            self.state.expanded = true
          }
        }
      Spacer()
    }
  }
  
  private var DetailBody: some View {
    HStack {
      VStack(alignment: .leading) {
        
        if let metadata = post.metadata {
          if let title = metadata.title {
            Text(title)
              .font(.title2)
              .foregroundColor(Color(.label))
              .bold()
          }
          
          if let description = metadata.description, description.isEmpty == false {
            Text(description)
              .font(.body)
              .foregroundColor(Color(.label))
          } else {
            Text("No description")
              .font(.body)
              .italic()
              .foregroundColor(Color(.label))
          }
        }
        
        Text(state.formattedDate)
          .font(.caption)
          .foregroundColor(Color(.label))
      }
      Spacer()
    }
    
  }
  
  private var Navbar: some View {
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
          self.state.showingProfile = true
        }
        .padding(.top, 8.0)
        .padding(.trailing, 16.0)
    }
  }
  
}
