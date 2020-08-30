//
//  Network.swift
//  Gyazo
//
//  Created by Markim Shaw on 4/22/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Alamofire
import Foundation
import Combine
import UIKit

struct Post: Hashable, Decodable {
  var title: String
}

class NetworkRequest<T: Decodable>: ObservableObject {
  
  typealias RequestType = T
  
  var cancellableSet: Set<AnyCancellable> = []
  
  var uploadPassthrough = PassthroughSubject<Double, Never>()

  
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
  
  func upload(image: UIImage?) {
    guard let accessToken = Secure.keychain["access_token"],
          let imageBinary = image?.jpegData(compressionQuality: 1.0) else {
      return // throw error or show some screen showing that this has failed
    }
    
    AF.upload(multipartFormData: { multipartFormData in
      multipartFormData.append(Data(accessToken.utf8), withName: "access_token")
      multipartFormData.append(imageBinary, withName: "imagedata", fileName: "iOS Share Menu", mimeType: "image/jpeg")
    }, to: "https://upload.gyazo.com/api/upload", method: .post)
    .responseDecodable(of: ImageResponse.self) { response in
      debugPrint(response)
    }
    .uploadProgress { progress in
      self.uploadPassthrough.send(progress.fractionCompleted)
    }
  }
}
