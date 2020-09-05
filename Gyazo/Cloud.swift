//
//  Cloud.swift
//  Gilmo
//
//  Created by Markim Shaw on 8/30/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation
import CloudKit
import SwiftUI

struct CloudDrop: Hashable, Identifiable {
  var title: String?
  var id: String
  var imageURL: String?
  var description: String?
  var app: String?
}

extension CKRecord.RecordType {
  static var gyazoRecord: String = "Resource"
}

class Cloud: ObservableObject {
  
  static var db = CKContainer.default().publicCloudDatabase
  
  static var resourceName: String = "Resource"
  
  var recordFetchedPassthrough: PassthroughSubject<CloudDrop, Never> = PassthroughSubject<CloudDrop, Never>()
  
  func save(_ post: Post) {
    let record = CKRecord(recordType: .gyazoRecord, recordID: .init(recordName: post.id))
    record.setValue(post.metadata?.title, forKey: "title")
    record.setValue(post.metadata?.app, forKey: "app")
    record.setValue(post.id + "-cloud", forKey: "gyazoID")
    record.setValue(post.urlString, forKey: "imageURL")
    record.setValue(post.metadata?.description, forKey: "description")
    
    Self.db.save(record) { _, _ in }
  }
  
  func retrieve(loadedCloudPostsBinding: Binding<Bool>) {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: .gyazoRecord, predicate: predicate)
//    query.sortDescriptors = [NSSortDescriptor(key: "Modified", ascending: false)]
    
    let operation = CKQueryOperation(query: query)
    
    operation.recordFetchedBlock = { record in
      let title = record.value(forKey: "title") as? String
      let id = record.value(forKey: "gyazoID") as? String
      let imageURL = record.value(forKey: "imageURL") as? String
      let description = record.value(forKey: "description") as? String
      let app = record.value(forKey: "app") as? String
      
      let post = CloudDrop(title: title, id: id ?? UUID().uuidString, imageURL: imageURL, description: description, app: app)
      DispatchQueue.main.async {
        self.recordFetchedPassthrough.send(post)
      }
    }
    
    operation.queryCompletionBlock = { cursor, error in
      if error == nil {
        
      }
      
    }
    
    operation.completionBlock = {
      DispatchQueue.main.async {
        loadedCloudPostsBinding.wrappedValue = true
      }
    }
    
    Self.db.add(operation)
    
  }
}
