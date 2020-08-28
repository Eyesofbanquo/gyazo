//
//  StretchyImageModifier.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/28/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

//struct StretchyImage: ViewModifier {
//  
//  var height: CGFloat
//
//  func body(content: Content) -> some View {
//    GeometryReader { g in
//      content
//        .resizable()
//        .aspectRatio(contentMode: .fill)
//        .frame(width: g.frame(in: .global).minY > 0 ? g.size.width + g.frame(in: .global).minY : g.size.width,
//               height: g.frame(in: .global).minY > 0 ? height + g.frame(in: .global).minY : height)
//        .clipped()
//        .offset(x: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY / 2 : 0, y: g.frame(in: .global).minY > 0 ? -g.frame(in: .global).minY : 0)
//      
//    }.frame(height: height)
//  }
//  
//}
//
//extension View {
//  func stretchyImage() -> some View {
//    self.modifier(StretchyImage(height: UIScreen.main.bounds.height / 2.2))
//  }
//}
