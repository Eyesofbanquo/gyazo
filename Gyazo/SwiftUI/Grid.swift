//
//  Grid.swift
//  Gyazo
//
//  Created by Markim Shaw on 8/23/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import SwiftUI

struct Grid<Content: View>: View {
  var column: Int
  var dataSource: [Drop] = []
  var content: (Drop) -> Content
  
  init(column: Int, dataSource: [Drop], content: @escaping (Drop) -> Content) {
    self.column = column
    self.dataSource = dataSource
    self.content = content
  }
  
  var body: some View {
     
    VStack(alignment: .leading) {
      ForEach(0..<self.rows) { r in
        HStack {
          ForEach(0..<self.column) { c in
            if self.getRowStartIndex(forRow: r) + c < self.dataSource.count {
              self.content(self.dataSource[self.getRowStartIndex(forRow: r) + c])
            }
          }
        }
      }
    }
  }
  
  var rows: Int {
    let remainder = dataSource.count % column // 2
    let subtractedCount = dataSource.count - remainder // 4
    
    // if remainder > 0 then +1 for rows
    
    let rowCount = Int(floor(Double(subtractedCount) / Double(column))) // 1
    
    let returnedRowCount = remainder > 0 ? rowCount + 1 : rowCount
    
    return returnedRowCount
  }
  
  func getRowStartIndex(forRow row: Int) -> Int {
    row * self.column
  }
}

struct Grid_Previews: PreviewProvider {
  static var previews: some View {
    Grid(column: 5, dataSource: Drop.stub, content: { drop in
      Text("hi")
    })
  }
}
