//
//  SelectedImageView.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct SelectedImageView: View {
  var uiimage: UIImage?
  
  var imageURL: String
  
  var actionText: (performedAction: String, default: String)
  
  @State private var performedAction: Bool = false
  
  @Binding var presentShareController: Bool
  
  var action: (() -> Void)?
  
  @Binding var presentSelectedImageView: Bool
  
  var body: some View {
    ZStack(alignment: .center) {
      Background
      VStack {
        DisplayableImage
        HStack(alignment: .center, spacing: 16.0) {
          ActionButton
          ShareButton
        }
      }
    }
    .edgesIgnoringSafeArea(.all)
    .transition(.scale)
    .onTapGesture {
      self.dismissAndReset()
    }
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
                        actionText: (performedAction: "Cancelled",
                                     default: "Tap on this to cancel"),
                        presentShareController: presentBinding, presentSelectedImageView: presentBinding)
        .preferredColorScheme(.dark)
      SelectedImageView(uiimage: UIImage(named: "gyazo-image"), imageURL: "https://i.redd.it/eog1gcl2ruj51.jpg",
                        actionText: (performedAction: "Cancelled",
                                     default: "Tap on this to cancel"),
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
  }
  
  private var ActionButton: some View {
    Button(action: {
      withAnimation {
        self.performedAction = true
      }
      self.action?()
    }) {
      Text("\(self.performedAction ? actionText.performedAction : actionText.default)")
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
  
  private func dismissAndReset() {
    self.$presentSelectedImageView.wrappedValue = false
    self.performedAction = false
  }
}
