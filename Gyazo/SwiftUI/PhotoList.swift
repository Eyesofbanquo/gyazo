////
////  PhotoList.swift
////  Gilmoyazo
////
////  Created by Markim Shaw on 9/5/20.
////  Copyright © 2020 Markim Shaw. All rights reserved.
////
//
//import Foundation
//import SwiftUI
//
//struct PhotoList: View {
//
//  var navigationTitle: String
//
//
//  var body: some View {
//    NavigationView {
//      content
//        .navigationTitle("Title")
//    }
//  }
//
//  private var content: some View {
//    photoListContentView
//  }
//
//  private var photoListContentView: some View {
//
//    ScrollView {
//      Section(header: photoListHeader) {
//        photoList
//      }
//    }
//  }
//
//  private var photoListHeader: some View {
//    HStack {
//      Text("Header")
//        .font(.headline)
//        .padding(.leading)
//      Spacer()
//    }
//  }
//
//  private var photoList: some View {
//    LazyVStack {
//      ForEach(photos) { photo in
//        photoClippedCell(photo: photo)
//      }
//    }
//  }
//
//  private func photoClippedCell(photo: Photo) -> some View {
//    Group {
//      Image("gyazo-image")
//        .resizable()
//        .aspectRatio(contentMode: .fill)
//        .frame(height: 300, alignment: .center)
//        .frame(minWidth: 0)
//        .overlay(backOverlay)
//        .cornerRadius(10.0)
//        .border(Color.red)
//        .clipped()
//        .padding()
//        .shadow(radius: 10)
//    }
//
//    .border(Color.red)
//    .clipped()
//  }
//
//  private func photoListCell(photo: Photo) -> some View {
//    Group {
//      Image("\(photo.image)")
//        .resizable()
//        .overlay(backOverlay)
//        .cornerRadius(10.0)
//        .frame(height: 300)
//        .aspectRatio(contentMode: .fit)
//        .padding()
//        .shadow(radius: 10)
//
//    }
//  }
//
//  private var imageOverlay: some View {
//    VStack(alignment: .trailing) {
//      Spacer()
//      Group {
//        HStack {
//          VStack(alignment: .leading) {
//            Text("Yikes")
//              .foregroundColor(.white)
//              .font(.headline)
//              .bold()
//            Text("August")
//              .foregroundColor(.white)
//              .font(.caption)
//          }
//          Spacer()
//        }
//        .padding(.horizontal, 16.0)
//      }
//    }
//    .padding(.top)
//  }
//
//  private var backOverlay: some View {
//    VStack(alignment: .trailing) {
//      Rectangle()
//        .background(Color.black)
//        .frame(height: 44)
//        .opacity(0.33)
//        .blur(radius: 32)
//        .overlay(imageOverlay)
//      Spacer()
//    }
//  }
//}
//
//struct PhotoList_Previews: PreviewProvider {
//  static var previews: some View {
//    PhotoList(navigationTitle: "Gyazo")
//  }
//}
