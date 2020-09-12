//
//  AsyncImage.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UIKit

public struct AsyncImage<Placeholder: View>: View {
  @ObservedObject private var loader: ImageLoader //needs to be inverted
  private let placeholder: Placeholder?
  
  private let configuration: (Image) -> Image
  
  init(url: URL,
       title: String? = nil,
       placeholder: Placeholder? = nil,
       cache: ImageCacheable? = nil,
       vision: Vision? = nil,
       configuration: @escaping (Image) -> Image = { $0 }) {
    loader = ImageLoader(url: url, title: title, cache: cache, vision: vision) // needs to be inverted
    self.placeholder = placeholder
    self.configuration = configuration
  }
  
  public var body: some View {
    image
      .onAppear(perform: loader.load)
  }
  
  private var image: some View {
    Group {
      if loader.image != nil {
        configuration(Image(uiImage: loader.image!))
      } else {
        placeholder
      }
    }
  }
}

