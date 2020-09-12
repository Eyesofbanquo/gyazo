//
//  AlamoCache.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/12/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import AlamofireImage
import Foundation
import SwiftUI

public struct AlamoCache: ImageCacheable {
  private let cache = AutoPurgingImageCache()
  
  public init() { }
  
  public subscript(_ key: URL) -> UIImage? {
    get {
      cache.image(withIdentifier: key.absoluteString)
    }
    set {
      cache.add(newValue!, withIdentifier: key.absoluteString)
    }
  }
}
