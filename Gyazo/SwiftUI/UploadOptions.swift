//
//  UploadOptions.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct UploadOptions: View {
  
  @State var showButtons = false
  
  @State var presentPhotoLibrary: Bool = false
  
  @State var presentCamera: Bool = false
  
  @Binding var clipboardImage: UIImage?
  
  @Binding var photoLibraryImage: UIImage?
  
  @Binding var cameraImage: UIImage?
  
  var body: some View {
    ZStack {
      Group {
        
        clipboardButton
        
        photoButton
        
        cameraButton
        
        uploadButton
      }
      .accentColor(.white)
      .animation(Animation.easeInOut(duration: 0.15))
    }
    
  }
  
  private var clipboardButton: some View {
    Button(action: {
      self.readFromPasteboard()
      self.showButtons = false
    }) {
      Image(systemName: "doc.on.clipboard")
        .padding(24)
        .rotationEffect(.degrees(showButtons ? 0 : -90))
    }
    .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
    .offset(x: 0, y: showButtons ? -128 : 0)
    .opacity(showButtons ? 1 : 0)
    
  }
  
  private var photoButton: some View {
    Button(action: {
      self.presentPhotoLibrary = true
      self.showButtons = false
    }) {
      Image(systemName: "photo")
        .padding(24)
        .rotationEffect(.degrees(showButtons ? 0 : -90))
    }
    .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
    .offset(x: showButtons ? -96 : 0, y: showButtons ? -92 : 0)
    .opacity(showButtons ? 1 : 0)
    .sheet(isPresented: $presentPhotoLibrary) { 
      ImagePicker(launchCamera: false, image: self.$photoLibraryImage)
    }
  }
  
  private var cameraButton: some View {
    Button(action: {
      self.presentCamera = true
      self.showButtons = false
    }) {
      Image(systemName: "camera")
        .padding(24)
        .rotationEffect(.degrees(showButtons ? 0 : -90))
      
    }
    .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
    .offset(x: showButtons ? -120 : 0, y: 0)
    .opacity(showButtons ? 1 : 0)
    .sheet(isPresented: $presentCamera) {
      ImagePicker(launchCamera: true, image: self.$photoLibraryImage)
    }
    
  }
  
  private var uploadButton: some View {
    Button(action: {
      self.showButtons.toggle()
    }) {
      Image(systemName: "icloud.and.arrow.up")
        .padding(24)
    }
    .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
  }
  
  private func readFromPasteboard() {
    let pasteboard = UIPasteboard.general
    guard let pasteboardImage = pasteboard.image else { return }

    self.clipboardImage = pasteboardImage
  }
}

struct UploadOptions_Previews: PreviewProvider {
  static var image: UIImage?
  
  static var clipboardImage =  Binding(get: { image }, set: { image = $0 })
  
  static var photoLibraryImage = Binding(get: { image }, set: { image = $0 })
  
  static var cameraImage = Binding(get: { image }, set: { image = $0 })
  
  static var previews: some View {
    UploadOptions(clipboardImage: clipboardImage, photoLibraryImage: photoLibraryImage, cameraImage: cameraImage)
  }
}

