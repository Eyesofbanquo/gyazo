//
//  ShareView.swift
//  GilmoShareExtension
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct ShareExtensionView: View {
  static var emoji: [String] = [
    "😎",
    "🥴",
    "😁",
    "😊",
    "😀",
    "🤪",
    "😜",
    "🤯",
    "🐼",
    "😍",
    "🐿",
  ]
  
  @Binding var selectedImage: UIImage?
  
  @Binding var dismiss: Bool
  
  @Binding var triggerUpload: Bool
  
  @State var progress: Float = 0.0
  
  @State var uploadImage: Bool = false
  
  var progressPassthrough: PassthroughSubject<Double, Never>
  
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    VStack {
      HStack {
        Button(action: {
          self.dismiss = true
        }) {
          Text("Cancel")
            .padding(.top)
            .foregroundColor(Color(.black))
          
        }.buttonStyle(PlainButtonStyle())
        
        Spacer()
      }
      Spacer()
      
      unwrappedImage?
        .resizable()
        .aspectRatio(contentMode: .fit)
        .cornerRadius(8)
        .shadow(radius: 8)
        .padding()
      
      if progress > 0.0 {
        VStack {
          ProgressView(value: progress)
            .transition(.slide)
            .accentColor(Color("gyazo-blue"))
          if progress == 1.0 {
            randomEmoji
              .transition(.scale)
          }
        }
        
      }
      
      Spacer()
      
      Button(action: {
        if self.uploadImage == false {
          withAnimation(Animation.easeInOut(duration: 0.05)) {
            self.uploadImage = true
          }
          withAnimation(Animation.spring()) {
            self.triggerUpload = true
          }
        }
      }) {
        if self.progress < 1.0 {
          Text(self.uploadImage ? "Uploading..." : "Upload to Gyazo")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.black))
            .foregroundColor(Color(.white))
            .cornerRadius(8.0)
        } else {
          Text("Uploaded!")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.black))
            .foregroundColor(Color(.white))
            .cornerRadius(8.0)
        }
        
      }.buttonStyle(PlainButtonStyle())
      
    }
    .padding()
    .background(Color(.white))
    .onReceive(progressPassthrough) { progress in
      withAnimation {
        self.progress = Float(progress)
      }
    }
  }
  
  var unwrappedImage: Image? {
    guard let image = selectedImage else { return nil }
    
    return Image(uiImage: image)
  }
  
  private var randomEmoji: some View {
    Group {
      if let randomEmoji = Self.emoji.randomElement() {
        Text("\(randomEmoji)")
          .font(.title)
      } else {
        EmptyView()
      }
    }
  }
}
