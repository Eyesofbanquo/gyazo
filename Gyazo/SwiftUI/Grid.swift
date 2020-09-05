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
  var dataSource: [Post] = []
  var content: (Post) -> Content
  
  init(column: Int, dataSource: [Post], content: @escaping (Post) -> Content) {
    self.column = column
    self.dataSource = dataSource
    self.content = content
  }
  
  var body: some View {
    Group {
      if column <= 0 {
        Text("Unable to load data")
          .font(.body)
          .italic()
      } else {
        ScrollView {
          VStack(alignment: .leading) {
            ForEach(0..<self.rows) { r in
              HStack {
                ForEach(0..<self.column) { c in
                  if self.getRowStartIndex(forRow: r) + c < self.dataSource.count {
                    self.content(self.dataSource[self.getRowStartIndex(forRow: r) + c])
                      .padding()
                  }
                  Spacer()
                }
              }
            }
            Spacer()
          }
        }
      }
    }
  }
  
  var rows: Int {
    guard column > 0 else { return 1 }
    
    let remainder = dataSource.count % column // 2
    let subtractedCount = dataSource.count - remainder // 4
    
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
    Grid(column: 2, dataSource: Post.stub, content: { drop in
      Image("gyazo-image")
        .resizable()
        .aspectRatio(contentMode: .fit)
    })
  }
}
