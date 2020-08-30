//
//  SelectedImageView.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

enum SelectedImageViewAction {
  case upload
  case clipboard
  case none
}

struct SelectedImageView: View {
  var uiimage: UIImage?
  
  var imageURL: String
  
  @State private var performedAction: Bool = false
  
  var action: SelectedImageViewAction
  
  @Binding var presentShareController: Bool
  
  @Binding var presentSelectedImageView: Bool
  
  @Environment(\.imageCache) var cache
  
  @StateObject var network: NetworkRequest<ImageResponse> = NetworkRequest<ImageResponse>()
  
  @State private var progress: Float = 0.0
  
  var body: some View {
    ZStack(alignment: .top) {
      ZStack(alignment: .center) {
        Background
        VStack(spacing: 16.0) {
          VStack(spacing: 2.0) {
            DisplayableImage
              .padding(.top)
            Progress
          }
          HStack(alignment: .center, spacing: 16.0) {
            ActionButton
            ShareButton
          }
        }
        .padding()
        
      }
      navbar
        .padding()
        .padding(.top)
    }
    .edgesIgnoringSafeArea(.all)
    .transition(.scale)
    .onTapGesture {
      self.dismissAndReset()
    }
    .onReceive(network.uploadPassthrough, perform: { results in
      self.progress = Float(results)
    })
    
  }
}

struct SelectedImageView_Previews: PreviewProvider {
  static var present: Bool = false
  
  static var presentBinding = Binding<Bool>(
    get: {
      return present
    },
    set: {
      present = $0
    })
  
  static var previews: some View {
    
    Group {
      SelectedImageView(uiimage: UIImage(named: "gyazo-image"), imageURL: "https://i.redd.it/eog1gcl2ruj51.jpg",
                        action: .upload,
                        presentShareController: presentBinding, presentSelectedImageView: presentBinding)
        .preferredColorScheme(.dark)
      SelectedImageView(uiimage: UIImage(named: "gyazo-image"), imageURL: "https://i.redd.it/eog1gcl2ruj51.jpg",
                        action: .clipboard,
                        presentShareController: presentBinding, presentSelectedImageView: presentBinding)
        .preferredColorScheme(.light)
    }
    
  }
}

// MARK: - Helpers -
extension SelectedImageView {
  var unwrappedImage: Image? {
    guard let image = uiimage else { return nil }
    
    return Image(uiImage: image)
  }
  
  private var DisplayableImage: some View {
    unwrappedImage?
      .resizable()
      .aspectRatio(contentMode: .fit)
      .cornerRadius(8.0)
      .padding()
  }
  
  private var ActionButton: some View {
    Button(action: {
      if self.performedAction == false {
        withAnimation {
          self.performedAction = true
          switch action {
            case .clipboard: self.copyToPasteboard()
            case .upload: self.network.upload(image: uiimage)
            default: break
          }
        }
      }
    }) {
      Text("\(actionText)")
        .padding()
        .foregroundColor(Color(.systemBackground))
        .background(self.performedAction ? Color(.label) : Color(.label))
        .clipShape(Capsule())
    }
  }
  
  private var ShareButton: some View {
    Button(action: {
      self.presentShareController = true
    }) {
      Image(systemName: "square.and.arrow.up")
        .font(.title)
    }.buttonStyle(PlainButtonStyle())
    .sheet(isPresented: self.$presentShareController, content: {
      if let image = uiimage, let imageURL = URL(string: self.imageURL) {
        ShareView(activityItems: [imageURL, image])
      } else {
        ShareView(activityItems: [])
      }
    })
  }
  
  private var Background: some View {
    Color.black
      .opacity(0.05)
      .background(BlurView(style: .systemMaterial))
  }
  
  private var Progress: some View {
    Group {
      if progress > 0.0 {
        ProgressView(value: progress)
          .accentColor(Color("gyazo-blue"))
      } else {
        EmptyView()
      }
    }
  }
  
  private var actionText: String {
    switch action {
      case .clipboard: return self.performedAction ? "Copied!" : "Copy to clipboard"
      case .upload:
        switch progress {
          case 0.0: return "Upload to Gyazo"
          case 0.01..<1.0: return "Uploading..."
          case 1.0: return "Uploaded!"
          default: return "Upload to Gyazo"
        }
      case .none: return ""
    }
  }
  
  private func dismissAndReset() {
    self.$presentSelectedImageView.wrappedValue = false
    self.performedAction = false
  }
  
  private func copyToPasteboard() {
    let pasteboard = UIPasteboard.general
    
    if let imageURL = URL(string: self.imageURL),
       let cachedImage = self.cache[imageURL] {
      pasteboard.image = cachedImage
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
              self.dismissAndReset()
            }
          }
        Spacer()
      }
    }
  }

}
