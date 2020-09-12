//
//  DashboardDetailVM.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/12/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine

struct DashboardDetailViewState {
  var expanded: Bool = false
  var formattedDate: String = ""
  var showingProfile: Bool = false
  var copiedText: Bool = false
  var shareController: Bool = false
}

class DashboardDetailVM: ObservableObject {
  
  // MARK: - Properties -
  
  var post: Post
  
  private var dateFormatter: DateFormat = DateFormat()
  
  private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
  
  // MARK: - Observables -
  
  @Published var postDate: String = ""
  
  init(post: Post) {
    self.post = post
  }
  
  func formatDate() {
    dateFormatter.format(fromString: post.createdAt)
      .receive(on: RunLoop.main)
      .assign(to: \.postDate, on: self)
      .store(in: &cancellables)
  }
}
