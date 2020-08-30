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
    if let data = postData {
      request.httpMethod = "POST"
      request.httpBody = postData
    } else {
      request.httpMethod = "GET"
    }

    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { $0.data }
      .decode(type: RequestType?.self, decoder: JSONDecoder())
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

    return cancellable
  }
  
  func post(usingImage image: UIImage?, withParams params: [String: String]) -> AnyPublisher<RequestType?, Never> {
    
    guard let url = URL(string: "https://upload.gyazo.com/api/upload"),
          let accessToken = Secure.keychain["access_token"],
          let image = image,
          let jpegData = image.jpegData(compressionQuality: 0.7) else {
      return PassthroughSubject<RequestType?, Never>().eraseToAnyPublisher()
    }
    
    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    let boundary = "Boundary-\(UUID().uuidString)"
//    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//    request.httpBody = createBody(parameters: params,
//                            boundary: boundary,
//                            data: jpegData,
//                            dataString: jpegData.base64EncodedString(),
//                            mimeType: "image/jpeg",
//                            filename: "hello.jpg")
    
    request.httpMethod = "POST"
    try? request.setMultipartFormData(params, encoding: .utf8)
    
    let cancellable = URLSession.shared.dataTaskPublisher(for: request)
      .map { $0.data }
      .decode(type: RequestType?.self, decoder: JSONDecoder())
      .replaceError(with: nil)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    
    return cancellable
  }
  
  func createBody(parameters: [String: String],
                  boundary: String,
                  data: Data,
                  dataString: String,
                  mimeType: String,
                  filename: String) -> Data {
    let body = NSMutableData()
    
    let boundaryPrefix = "--\(boundary)\r\n"
    
    for (key, value) in parameters {
      if (key == "imagedata") {
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"iphoneImage.JPG\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.appendString("\(value)\r\n")
        continue
      }
      body.appendString(boundaryPrefix)
      body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
      body.appendString("\(value)\r\n")
    }
    
//    body.appendString(boundaryPrefix)
//    body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
//    body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//    body.appendString("\(dataString)")
//    body.appendString("\r\n")
    body.appendString("--".appending(boundary.appending("--")))
    
    return body as Data
  }

  func add(_ cancellable: AnyCancellable?) {
    guard let c = cancellable else { return }

    cancellableSet.insert(c)
  }
}

extension NSMutableData {
  func appendString(_ string: String) {
    let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
    append(data!)
  }
}

extension URLRequest {
  
  /**
   Configures the URL request for `multipart/form-data`. The request's `httpBody` is set, and a value is set for the HTTP header field `Content-Type`.
   
   - Parameter parameters: The form data to set.
   - Parameter encoding: The encoding to use for the keys and values.
   
   - Throws: `MultipartFormDataEncodingError` if any keys or values in `parameters` are not entirely in `encoding`.
   
   - Note: The default `httpMethod` is `GET`, and `GET` requests do not typically have a response body. Remember to set the `httpMethod` to e.g. `POST` before sending the request.
   - Seealso: https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#multipart-form-data
   */
  public mutating func setMultipartFormData(_ parameters: [String: String], encoding: String.Encoding) throws {
    
    let makeRandom = { UInt32.random(in: (.min)...(.max)) }
    let boundary = String(format: "------------------------%08X%08X", makeRandom(), makeRandom())
    
    let contentType: String = try {
      guard let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)) else {
        throw MultipartFormDataEncodingError.characterSetName
      }
      return "multipart/form-data; boundary=\(boundary)"
    }()
    addValue(contentType, forHTTPHeaderField: "Content-Type")
    
    httpBody = try {
      var body = Data()
      
      for (rawName, rawValue) in parameters {
        if !body.isEmpty {
          body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        guard
          rawName.canBeConverted(to: encoding),
          let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: encoding) else {
          throw MultipartFormDataEncodingError.name(rawName)
        }
        body.append(disposition)
        
        body.append("\r\n".data(using: .utf8)!)
        
        guard let value = rawValue.data(using: encoding) else {
          throw MultipartFormDataEncodingError.value(rawValue, name: rawName)
        }
        
        body.append(value)
      }
      
      body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
      
      return body
    }()
  }
}

public enum MultipartFormDataEncodingError: Error {
  case characterSetName
  case name(String)
  case value(String, name: String)
}
