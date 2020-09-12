//
//  StretchyHeader.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/12/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
  func asStretchyHeader(in proxy: GeometryProxy, withHeight height: CGFloat = UIScreen.main.bounds.height / 2.2) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(width: StretchyHeaderCalculator.calculateWidth(in: proxy, forHeight: height),
             height: StretchyHeaderCalculator.calculateHeight(in: proxy, forHeight: height))
      .clipped()
      .offset(x: StretchyHeaderCalculator.calculateXOffset(in: proxy, forHeight: height),
              y: StretchyHeaderCalculator.calculateYOffset(in: proxy, forHeight: height))
  }
}

struct StretchyHeaderCalculator {
  
  fileprivate static func calculateXOffset(in proxy: GeometryProxy, forHeight height: CGFloat) -> CGFloat {
    proxy.frame(in: .global).minY > 0 ? -proxy.frame(in: .global).minY / 2 : 0
  }
  
  fileprivate static func calculateYOffset(in proxy: GeometryProxy, forHeight height: CGFloat) -> CGFloat {
    proxy.frame(in: .global).minY > 0 ? -proxy.frame(in: .global).minY : 0
  }
  
  fileprivate static func calculateWidth(in proxy: GeometryProxy, forHeight height: CGFloat) -> CGFloat {
    proxy.frame(in: .global).minY > 0 ? proxy.size.width + proxy.frame(in: .global).minY : proxy.size.width
  }
  
  fileprivate static func calculateHeight(in proxy: GeometryProxy, forHeight height: CGFloat) -> CGFloat {
    proxy.frame(in: .global).minY > 0 ? UIScreen.main.bounds.height / 2.2 + proxy.frame(in: .global).minY : UIScreen.main.bounds.height / 2.2
  }
}
