//
//  DateFormat.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/28/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine

class DateFormat: ObservableObject {
  
  lazy var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy HH:mm"
    
    return formatter
  }()
  
  func format(fromString dateString: String?) -> Future<String, Never> {
    return Future<String, Never> { [self] seal in
      guard let dateString = dateString else {
        seal(.success("Unable to parse time"))
        return
      }
      
      let localISOFormatter = ISO8601DateFormatter()
      localISOFormatter.timeZone = TimeZone.current
      guard let dateObject = localISOFormatter.date(from: dateString) else {
        seal(.success("Unable to parse time"))
        return
      }
      
      let newDateString = self.formatter.string(from: dateObject)
      
      seal(.success(newDateString))
    }
  }
}
