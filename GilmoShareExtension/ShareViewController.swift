//
//  ShareViewController.swift
//  GilmoShareExtension
//
//  Created by Markim Shaw on 8/29/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Alamofire
import UIKit
import Social
import MobileCoreServices
import Combine
import SwiftUI

@objc(ShareViewController)
class ShareViewController: UIViewController {
  
//  self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

  @Published var image: UIImage?
  
  private var dismissView: Bool = false
  
  private var triggerUpload: Bool = false
  
  private var network: NetworkRequest<ImageResponse> = NetworkRequest<ImageResponse>()
  private var cancellable: AnyCancellable?
  
  private var passthrough = PassthroughSubject<Double, Never>()
  
  @State var progress: Float = 0.0
  
  lazy var progressBinding = Binding (
    get: {
      self.progress
    },
    set: { newValue in
      self.progress = newValue
    })
  
  lazy var triggerUploadBinding = Binding (
    get: {
      self.triggerUpload
    },
    set: { newValue in
      
      if newValue {
        self.triggerUpload = newValue
        self.uploadImage()
      }
      
    })
  
  lazy var dismissViewBinding = Binding (
    get: {
      return self.dismissView
    },
    set: { newValue in
      if newValue {
        self.dismissView = newValue
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
      }
    }
  )
  
  lazy var imageBinding = Binding (
    get: {
      return self.image
    },
    set: {
      self.image = $0
    }
  )
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let content = extensionContext!.inputItems[0] as! NSExtensionItem
    let contentType = kUTTypeImage as String
    
    for attachment in content.attachments! as [NSItemProvider] {
      if attachment.hasItemConformingToTypeIdentifier(contentType) {
        attachment.loadItem(forTypeIdentifier: contentType, options: nil) { (data, error) in
          guard error == nil else {
            print("this failed")
            return
          }
          let url = data as! URL
          if let imageData = try? Data(contentsOf: url) {
            self.image = UIImage(data: imageData)
          }
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let childView = UIHostingController(rootView: ShareExtensionView(selectedImage: imageBinding,
                                                                     dismiss: dismissViewBinding,
                                                                     triggerUpload: triggerUploadBinding,
                                                                     progressPassthrough: passthrough))
    addChild(childView)
    childView.view.frame = view.frame
    view.addSubview(childView.view)
    childView.didMove(toParent: self)
  }
  
  private func uploadImage() {
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
      DispatchQueue.main.async {
        self.passthrough.send(progress.fractionCompleted)
      }
    }
  }

}
