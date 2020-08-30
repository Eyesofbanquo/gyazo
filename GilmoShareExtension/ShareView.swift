//
//  ShareView.swift
//  GilmoShareExtension
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct ShareExtensionView: View {
  @Binding var selectedImage: UIImage?
  
  @Binding var dismiss: Bool
  
  @Binding var triggerUpload: Bool
  
  @State var uploadImage: Bool = false
  
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    VStack {
      HStack {
        Button(action: {
          self.dismiss = true
        }) {
          Text("Cancel")
            .padding(.top)
            .foregroundColor(Color(.label))
          
        }.buttonStyle(PlainButtonStyle())
        
        Spacer()
      }
      Spacer()
      unwrappedImage?
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding()
      Button(action: {
        withAnimation(Animation.easeInOut(duration: 0.05)) {
          self.uploadImage = true
        }
        self.triggerUpload = true
      }) {
        Text(self.uploadImage ? "Uploading..." : "Upload to Gyazo")
          .padding()
          .background(Color(.label))
          .foregroundColor(Color(.systemBackground))
          .clipShape(Capsule())
      }.buttonStyle(PlainButtonStyle())
      Spacer()
    }.padding()
  }
  
  var unwrappedImage: Image? {
    guard let image = selectedImage else { return nil }
    
    return Image(uiImage: image)
  }
}
