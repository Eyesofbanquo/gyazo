//
//  ImageLoader.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine
import Foundation
import SwiftUI

public class ImageLoader: ObservableObject {
  
  private static let imageProcessingQueue = DispatchQueue(label: "image-loading")
  
  @Published var image: UIImage?
  
  private var cancellable: AnyCancellable?
  
  private let url: URL
  
  private var title: String?
  
  private var cache: ImageCacheable?
  
  private(set) var isLoading: Bool = false
  
  private var vision: Vision?
  
  init(url: URL,
       title: String? = nil,
       cache: ImageCacheable? = nil,
       vision: Vision? = nil) {
    self.url = url
    self.cache = cache
    self.vision = vision
    self.title = title
  }
  
  deinit {
    cancellable?.cancel()
  }
  
  func load() {
    guard isLoading == false else { return }
    
    if let image = cache?[url] {
      self.image = image
      return
    }
    
    cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .subscribe(on: Self.imageProcessingQueue)
      .map { UIImage(data: $0.data) }
      .replaceError(with: nil)
      .handleEvents(
        receiveSubscription: { [weak self] _ in self?.onStart() },
        receiveOutput: { [weak self] image in
          if let downloadedImage = image {
            self?.vision?.classifyImage(downloadedImage, forId: self?.title ?? "")
          }
          self?.cache(image)
        },
        receiveCompletion: { [weak self] _ in self?.onFinish() },
        receiveCancel: { [weak self] in self?.onFinish() }
    )
      .receive(on: DispatchQueue.main)
      .assign(to: \.image, on: self)
  }
  
  private func cache(_ image: UIImage?) {
    image.map { cache?[url] = $0 }
  }
  
  private func onStart() {
    isLoading = true
  }
  
  private func onFinish() {
    isLoading = false
  }
  
  func cancel() {
    cancellable?.cancel()
  }
}
