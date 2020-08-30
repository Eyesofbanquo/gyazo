//
//  Network.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine
import UIKit

struct Post: Hashable, Decodable {
  var title: String
}

class NetworkRequest<T: Decodable>: ObservableObject {
  
  typealias RequestType = T
  
  var cancellableSet: Set<AnyCancellable> = []
  
  func request(endpoint: GyazoAPI.Endpoint, postData: Data? = nil) -> AnyPublisher<RequestType?, Never> {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.gyazo.com"
    components.path = "/api/\(endpoint.path)"
    
    guard let url = components.url, let accessToken = Secure.keychain["access_token"] else {
      return PassthroughSubject<RequestType?, Never>().eraseToAnyPublisher()
    }
    
    var request = URLRequest(url: url)
    
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    request.httpMethod = "GET"

    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { $0.data }
      .decode(type: RequestType?.self, decoder: JSONDecoder())
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

    return cancellable
  }
}
