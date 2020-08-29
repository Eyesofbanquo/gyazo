//
//  Profile.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/25/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct Profile: View {
  
  @ObservedObject var network: NetworkRequest = NetworkRequest<UserContainer>()
  
  @State var user: User?
  
  @Environment(\.presentationMode) var presentationMode
  
  @Environment(\.openURL) var openURL
  
  @Environment(\.oauthKey) var oauth
  
  var body: some View {
    ZStack {
        VStack(spacing: 8.0) {
          
          HStack {
            Image(systemName: "plus")
              .foregroundColor(Color(.systemBackground))
              .rotationEffect(.radians(.pi/4))
              .padding()
              .background(Circle().foregroundColor(Color(.label)))
              .padding([.leading, .top])
              .onTapGesture {
                self.presentationMode.wrappedValue.dismiss()
              }
            Spacer()
          }
          
          Image("gyazo-image")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(Circle())
          
          GeometryReader { h in
            VStack(spacing: 16.0) {
              VStack {
                Text(user?.name ?? "")
                  .font(.headline)
                  .frame(maxWidth: .infinity)
                Text(user?.email ?? "")
                  .font(.subheadline)
              }
              Button(action: {
                openURL(URL(string: "https://www.gyazo.com/captures")!)
              }) {
                Text("Check profile online")
                  .bold()
                  .padding()
                  .background(Color(.label))
                  .foregroundColor(Color(.systemBackground))
                  .clipShape(Capsule())
              }.buttonStyle(PlainButtonStyle())
              
              Spacer()
              Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                  self.oauth.logout()
                  NotificationCenter.default.post(name: .loggedOut, object: nil, userInfo: nil)
                }
              }) {
                Text("logout")
                  .bold()
                  .padding()
                  .background(Color(.systemRed))
                  .foregroundColor(.white)
                  .clipShape(Capsule())
              }.buttonStyle(PlainButtonStyle())
            }
            
          Spacer()
        }
      }
      
    }
    .onReceive(network.request(endpoint: .user)) { container in
      self.user = container?.user
      
    }
  }
}

struct Profile_Providers: PreviewProvider {
  static var previews: some View {
    Group {
      Profile(user: User(email: "markim@linuxacademy.com", name: "Markim Shaw", profileImage: nil, id: "1"))
        .preferredColorScheme(.dark)
      Profile(user: User(email: "markim@linuxacademy.com", name: "Markim Shaw", profileImage: nil, id: "1"))
        .preferredColorScheme(.light)
    }
  }
}
