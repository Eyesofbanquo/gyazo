//
//  Network.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine

struct Post: Hashable, Decodable {
  var title: String
}

class NetworkRequest<T: Decodable>: ObservableObject {
  
  typealias RequestType = T
  
  var cancellableSet: Set<AnyCancellable> = []

//  func request(_ completion: ((AnyPublisher<[Post], Never>) -> AnyCancellable?)? = nil) {
//    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
//    let cancellable = URLSession.shared.dataTaskPublisher(for: url)
//      .map { $0.data}
//      .decode(type: [Post].self, decoder: JSONDecoder())
//      .replaceError(with: [])
//      .eraseToAnyPublisher()
//
//    let c = completion?(cancellable)
//
//    self.add(c)
//  }

  func request(endpoint: String) -> AnyPublisher<RequestType?, Never> {
//    let url = URL(string: "https://api.gyazo.com/api/\(endpoint)")!
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.gyazo.com"
    components.path = "/api/\(endpoint)"
    
    guard let url = components.url, let accessToken = Secure.keychain["access_token"] else {
      return PassthroughSubject<RequestType?, Never>().eraseToAnyPublisher()
    }
    
    var request = URLRequest(url: url)
    
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"
//    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
//    let request = URLRequest(url: url)

    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { $0.data }
      .decode(type: RequestType?.self, decoder: JSONDecoder())
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

    return cancellable
  }

  func add(_ cancellable: AnyCancellable?) {
    guard let c = cancellable else { return }

    cancellableSet.insert(c)
  }
}
