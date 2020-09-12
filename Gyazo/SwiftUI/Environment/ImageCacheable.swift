//
//  ImageCacheable.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

public protocol ImageCacheable {
  subscript(_ url: URL) -> UIImage? { get set }
}

public struct ImageCacheKey: EnvironmentKey {
  public static let defaultValue: ImageCacheable = AlamoCache()
}

extension EnvironmentValues {
  public var imageCache: ImageCacheable {
    get { self[ImageCacheKey.self] }
    set { self[ImageCacheKey.self] = newValue }
  }
}
