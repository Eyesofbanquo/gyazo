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

struct CloudDrop: Hashable {
  var title: String?
  var id: String?
  var imageURL: String?
  var description: String?
}

extension CKRecord.RecordType {
  static var gyazoRecord: String = "Resource"
}

class Cloud: ObservableObject {
  
  static var db = CKContainer.default().publicCloudDatabase
  
  static var resourceName: String = "Resource"
  
  var recordFetchedPassthrough: PassthroughSubject<CloudDrop, Never> = PassthroughSubject<CloudDrop, Never>()
  
  func save(_ post: Drop) {
    let record = CKRecord(recordType: .gyazoRecord, recordID: .init(recordName: post.id))
    record.setValue(post.metadata?.title, forKey: "title")
    record.setValue(post.id, forKey: "gyazoID")
    record.setValue(post.urlString, forKey: "imageURL")
    record.setValue(post.metadata?.description, forKey: "description")
    
    Self.db.save(record) { _, _ in }
  }
  
  func retrieve() {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: .gyazoRecord, predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
    
    let operation = CKQueryOperation(query: query)
    
    operation.recordFetchedBlock = { record in
      let title = record.value(forKey: "title") as? String
      let id = record.value(forKey: "gyazoID") as? String
      let imageURL = record.value(forKey: "imageURL") as? String
      let description = record.value(forKey: "description") as? String
      
      let post = CloudDrop(title: title, id: id, imageURL: imageURL, description: description)
      DispatchQueue.main.async {
        self.recordFetchedPassthrough.send(post)
      }
    }
    
    operation.queryCompletionBlock = { cursor, error in
      DispatchQueue.main.async {
        print(cursor)
      }
    }
    
    Self.db.add(operation)
    
  }
}
