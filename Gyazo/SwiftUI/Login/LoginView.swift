//
//  LoginView.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/24/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

struct LoginView: View {
  
  @ObservedObject var loginController: LoginInterceptViewController
  
  var body: some View {
    ZStack(alignment: .center) {
      GeometryReader { g in
        VStack(alignment: .center) {
          Spacer()
          Image("gyazo-logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: g.size.height / 3)
          
          Text("Gyazo")
            .bold()
            .frame(maxWidth: .infinity)
            .font(.title)
          Spacer()
          Spacer()
          Button(action: {
            self.loginController.authorizeIfNeeded()
          }) {
            Text("Login")
              .font(.headline)
              .foregroundColor(Color(.systemBackground))
              .padding(.horizontal, 32.0)
              .padding(.top, 16.0)
              .padding(.bottom, 16.0)
              .background(Color(.label))
              .clipShape(Capsule())
              
          }
          .buttonStyle(PlainButtonStyle())
        }
      }.padding(.bottom)
    }
    .edgesIgnoringSafeArea(.all)
    .background(Color(.systemBackground))
  }
}

struct LoginView_Previews: PreviewProvider {
  
  static var previews: some View {
    Group {
      LoginView(loginController: LoginInterceptViewController())
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
        .previewDevice(.init(stringLiteral: "iPhone 11 Pro Max"))
      LoginView(loginController: LoginInterceptViewController())
        .preferredColorScheme(.light)
    }
  }
}
