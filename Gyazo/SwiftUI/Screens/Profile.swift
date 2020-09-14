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
  
  @EnvironmentObject var appMachine: AppMachine
  
  @State var loggingOut: Bool = false
  
  @Binding var presented: Bool
  
  var body: some View {
    ZStack {
        VStack(spacing: 8.0) {
          
          HStack {
            Button(action: {
              self.presentationMode.wrappedValue.dismiss()

            }) {
              Image(systemName: "plus")
                .foregroundColor(Color(.systemBackground))
                .rotationEffect(.radians(.pi/4))
                .padding()
                .background(Circle().foregroundColor(Color(.label)))
                .padding([.leading, .top])
            }.buttonStyle(PlainButtonStyle())
           
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
                self.loggingOut = true
                self.oauth.logout()
                self.appMachine.send(.restart)
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
      if loggingOut {
        ZStack(alignment: .center) {
          Color.white.opacity(0.1).background(BlurView(style: .systemMaterial))
          VStack {
            Text("Logged Out")
              .font(.title)
            Button(action: {
              self.$presented.wrappedValue = false
            }) {
              Text("Tap to dismiss")
                .padding()
                .background(Color(.label))
                .foregroundColor(Color(.systemBackground))
                .clipShape(Capsule())
            }
            Text("Experimental build. You can't completely logout of Gyazo with this button. This button just guarantees that someone can't access your content but Safari still stores your session. Delete this app to completely logout.")
              .padding()
              .padding(.horizontal)
              .font(.caption2)
          }
        }.edgesIgnoringSafeArea(.all)
      }
      
    }
    .onReceive(network.request(endpoint: .user)) { container in
      self.user = container?.user
      
    }
  }
}

struct Profile_Providers: PreviewProvider {
  private static var presented: Bool = false
  private static var presentedBinding = Binding<Bool> (
    get: {
      presented
    },
    set: {
      presented = $0
    })
  static var previews: some View {
    Group {
      Profile(user: User(email: "markim@linuxacademy.com", name: "Markim Shaw", profileImage: nil, id: "1"), presented: presentedBinding)
        .preferredColorScheme(.dark)
      Profile(user: User(email: "markim@linuxacademy.com", name: "Markim Shaw", profileImage: nil, id: "1"), presented: presentedBinding)
        .preferredColorScheme(.light)
    }
  }
}
