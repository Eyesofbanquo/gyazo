//
//  SearchBar.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct SearchBar: View {
  
  @Binding var text: String
  
  @State private var isEditing = false
  
  @State private var cancelButtonIsVisible = false
  
  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      TextField("Search...", text: $text)
        .onTapGesture {
          withAnimation(Animation.default) {
            self.isEditing = true
          }
          
          withAnimation(Animation.default.delay(0.2)) {
            self.cancelButtonIsVisible = true
          }
      }
      .padding(8)
      .padding(.horizontal, 24)
      .background(Color(.systemGray6))
      .cornerRadius(8)
      .overlay(HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(Color.gray)
          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 8)
        
        if self.isEditing {
          Button(action: {
            self.text = ""
            print("yo")
          }) {
            Image(systemName: "multiply.circle.fill")
              .foregroundColor(.gray)
              .padding(.trailing, 8)
          }
          .opacity(cancelButtonIsVisible ? 1 : 0)
        }
      })
      .padding(.horizontal, 10)
      
      if isEditing {
        Button(action: {
          withAnimation(Animation.default) {
            self.isEditing = false
          }
          
          withAnimation(Animation.default.delay(0.2)) {
            self.cancelButtonIsVisible = false
          }
          
          self.text = ""
        }) {
          Text("Cancel")
        }.buttonStyle(PlainButtonStyle())
          .padding(.horizontal, 8)
          .opacity(cancelButtonIsVisible ? 1 : 0)
          .transition(.move(edge: .trailing))
      }
    }
    
    
  }
}

struct SearchBar_Previews: PreviewProvider {
//  static var searchText: String = "Search..."
  static var previews: some View {
    SearchBar(text: .constant(""))
  }
}
