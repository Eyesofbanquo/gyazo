//
//  ImageLoader.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import AlamofireImage
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
  
  private let downloader: ImageDownloader
  
  init(url: URL,
       title: String? = nil,
       cache: ImageCacheable? = nil,
       vision: Vision? = nil) {
    self.url = url
    self.cache = cache
    self.vision = vision
    self.title = title
    
    self.downloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(),
                                      downloadPrioritization: .fifo,
                                      maximumActiveDownloads: 4)
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
    
    cancellable = Future<UIImage?, Never> { seal in
      self.downloader.download(URLRequest(url: self.url), completion: { response in
        if case .success(let image) = response.result {
          self.cache?[self.url] = image
          seal(.success(image))
        }
      })
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.image, on: self)
  }
  
  func loadPublisher() -> Future<Bool, Never> {
    return Future<Bool, Never> { seal in
      self.cancellable = URLSession.shared.dataTaskPublisher(for: self.url)
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
          receiveCancel: { [weak self] in
            self?.onFinish()
          }
        )
        .receive(on: DispatchQueue.main)
        .sink { image in
          self.image = image
          seal(.success(true))
        }
    }
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
