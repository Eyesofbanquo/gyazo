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
  
  var body: some View {
    VStack(spacing: 8.0) {
      
      HStack {
        Image(systemName: "plus")
          .foregroundColor(.white)
          .rotationEffect(.radians(.pi/4))
          .padding()
          .background(Circle().foregroundColor(Color(.systemTeal)))
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
      Text(user?.name ?? "")
        .font(.headline)
      Text(user?.email ?? "")
        .font(.subheadline)
      
      Spacer()
      
      VStack(spacing: 8.0) {
        Text("some other bs")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color(.systemTeal))
          .foregroundColor(.white)
        Text("logout")
          .bold()
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.red)
          .foregroundColor(.white)
        
      }.padding(.bottom)
    }
    .onReceive(network.request(endpoint: "users/me")) { container in
      self.user = container?.user
      
    }
  }
}

struct Profile_Providers: PreviewProvider {
  static var previews: some View {
    Profile(user: User(email: "markim@linuxacademy.com", name: "Markim Shaw", profileImage: nil, id: "1"))
  }
}
