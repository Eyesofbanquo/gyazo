//
//  ImagePicker.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIImagePickerController
  
  @Binding var image: UIImage?
  
  @Environment(\.presentationMode) var presentationMode
  
  func makeCoordinator() -> Coordinator {
    ImagePicker.Coordinator(self)
  }
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .photoLibrary
    //picker.sourceType = .camera
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    print("this is called")
  }
}

extension ImagePicker {
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      if let uiImage = info[.originalImage] as? UIImage {
        parent.image = uiImage
      }
      
      parent.presentationMode.wrappedValue.dismiss()
    }
  }
}

// MARK: - This is for quick testing -

struct ImagePickerView: View {
  
  @State private var imageView: Image?
  @State private var image: UIImage?
  @State var showingImagePicker = false
  
  var body: some View {
    VStack {
      imageView?.resizable().aspectRatio(contentMode: .fit)
      Button("Tap to present picker") {
        self.showingImagePicker = true
      }
    }.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
      ImagePicker(image: self.$image)
    }
  }
  
  func loadImage() {
    guard let image = self.image else { return }
    imageView = Image(uiImage: image)
  }
}

struct ImagePicker_Previews: PreviewProvider {
  static var previews: some View {
    ImagePickerView()
  }
}
