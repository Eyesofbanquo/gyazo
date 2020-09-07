//
//  TempImageCache.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

class RetainedImageCache: NSObject , NSDiscardableContent {
  
  public var image: UIImage?
  
  func beginContentAccess() -> Bool {
    return true
  }
  
  func endContentAccess() {
    
  }
  
  func discardContentIfPossible() {
    
  }
  
  func isContentDiscarded() -> Bool {
    return false
  }
}

public struct TemporaryImageCache: ImageCacheable {
  private let cache = NSCache<NSURL, RetainedImageCache>()
  
  public init() { }
  
  public subscript(_ key: URL) -> UIImage? {
    get { cache.object(forKey: key as NSURL)?.image }
    set {
      if newValue == nil {
        cache.removeObject(forKey: key as NSURL)
      } else {
        let retained = RetainedImageCache()
        retained.image = newValue
        cache.setObject(retained, forKey: key as NSURL)}
    }
  }
}
