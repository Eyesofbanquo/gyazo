//
//  Vision.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision
import SwiftUI

class Vision: ObservableObject {
  
  @Published var classifications: [String: [(VNConfidence, String)]] = [:]
  
  private var model: VNCoreMLModel?
  
  func classificationRequest(forId id: String) -> VNCoreMLRequest {
    do {
      if model == nil {
        let model = try VNCoreMLModel(for: SqueezeNet().model)
        self.model = model
      }
      
      let request = VNCoreMLRequest(model: model!) { request, _ in
        if let classifications = request.results as? [VNClassificationObservation] {
          self.classifications[id] = classifications.prefix(2).map {
            (confidence: $0.confidence, identifier: $0.identifier)
          }
          print(self.classifications)
        }
      }
      
      request.imageCropAndScaleOption = .centerCrop
      return request
    } catch {
      fatalError()
    }
  }
  
  func classifyImage(_ image: UIImage, forId id: String) {
    guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
      return
    }
    
    guard let ciImage = CIImage(image: image) else {
      fatalError("Unable to make CIImage from UIImage")
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
      do {
        try handler.perform([self.classificationRequest(forId: id)])
      } catch {
        print("Failure")
      }
    }
  }
}

struct VisionKey: EnvironmentKey {
  static let defaultValue: Vision = Vision()
}


extension EnvironmentValues {
  var vision: Vision {
    get { self[VisionKey.self] }
    set { self[VisionKey.self] = newValue }
  }
}

