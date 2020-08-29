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
  
  var actionText: (performedAction: String, default: String)
  
  @State private var performedAction: Bool = false
  
  private var action: (() -> Void)?
  
  @Binding var presentSelectedImageView: Bool
  
  var body: some View {
    ZStack(alignment: .center) {
      Color.black
        .opacity(0.05)
        .background(BlurView(style: .systemMaterial))
      VStack {
        unwrappedImage?
          .resizable()
          .aspectRatio(contentMode: .fit)
        Text("\(self.performedAction ? actionText.performedAction : actionText.default)")
          .padding()
          .foregroundColor(Color(.systemBackground))
          .background(self.performedAction ? Color(.label) : Color(.label))
          .clipShape(Capsule())
          .onTapGesture {
            withAnimation {
              self.performedAction = true
            }
            self.action?()
          }
      }
    }
    .edgesIgnoringSafeArea(.all)
    .transition(.scale)
    .onTapGesture {
      self.$presentSelectedImageView.wrappedValue = false
      self.performedAction = false
    }
  }
  
  var unwrappedImage: Image? {
    guard let image = uiimage else { return nil }
    
    return Image(uiImage: image)
  }
}

struct SelectedImageView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      SelectedImageView()
        .preferredColorScheme(.dark)
      SelectedImageView()
        .preferredColorScheme(.light)
    }
  }
}
