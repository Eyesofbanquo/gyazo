//
//  Network.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine

class Network: ObservableObject {
  
  @Published var posts: [Post] = []
  
  var cancellableSet: Set<AnyCancellable> = []
    
  func request(_ completion: ((AnyPublisher<[Post], Never>) -> AnyCancellable?)? = nil) {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    let cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { $0.data}
      .decode(type: [Post].self, decoder: JSONDecoder())
      .replaceError(with: [])
      .eraseToAnyPublisher()
    
    let c = completion?(cancellable)
    
    self.add(c)
  }
  
  func requestPublisher() -> AnyPublisher<[Post], Never> {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    let cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { $0.data}
      .decode(type: [Post].self, decoder: JSONDecoder())
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    return cancellable
  }
  
  func add(_ cancellable: AnyCancellable?) {
    guard let c = cancellable else { return }
    
    cancellableSet.insert(c)
  }
}
