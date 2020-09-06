//
//  ContentViewModel.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/5/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct ContentViewState {
  var searchText: String = ""
  var showingProfile = false
  var uploadImage: UIImage?
  var presentShareController = false
  var presentDashboardCell = false
  var selectedPost: Post?
  var loadedCloudPosts: Bool = false
  
  var detailViewAnimation: Namespace = Namespace.init()
  var detailViewAnimationID: Namespace.ID {
    return detailViewAnimation.wrappedValue
  }
}

class ContentViewModel: ObservableObject {
  
  // MARK: - Observables -
  
  var vision: Vision = VisionKey.defaultValue
  
  var request: NetworkRequest<[Post]> = NetworkRequest<[Post]>()
  
  var cloud: Cloud = Cloud()
    
  // MARK: - Data -
  
  @Published private(set) var posts: [Post] = []
  
  @Published private(set) var cloudPosts: [CloudPost] = []
  
  var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
  
  func retrievePosts() {
    request.request(endpoint: .images)
      .receive(on: DispatchQueue.main)
      .compactMap { $0 }
      .map { $0.filter { $0.id.isEmpty == false } }
      .assign(to: \.posts, on: self)
      .store(in: &cancellables)
  }
  
  func retrieveCloudPosts() {
    cloud.retrieve()
      .receive(on: RunLoop.main)
      .sink { retrievedCloudPosts in
        for cloudPost in retrievedCloudPosts {
          if self.posts.first(where: { $0.urlString == cloudPost.imageURL } ) == nil && self.cloudPosts.first(where: { $0.id == cloudPost.id }) == nil {
            self.cloudPosts.append(cloudPost)
          }
        }
      }
      .store(in: &cancellables)
  }
  
  func filterSearchResults(_ post: Post, forText searchText: String) -> Bool {
    if (searchText.isEmpty) {
      return true
    } else {
      let appropriateMLResponses = self.vision.classifications[post.metadata?.title ?? ""]
      let bestResponse = appropriateMLResponses?.first
      let searchTextContainsResponse = (bestResponse?.1.lowercased() ?? "").contains(searchText.lowercased())
      return (post.metadata?.app?.contains(searchText)) == true || (post.metadata?.title?.contains(searchText)) == true || searchTextContainsResponse == true
    }
  }
  
  func cloudSearchAndFilter(_ cloud: CloudPost, forText searchText: String) -> Bool {
    let alreadyExists = self.posts.first(where: { $0.id == cloud.id }) != nil
    let emptySearch = searchText.isEmpty
    
    if alreadyExists {
      return true
    }
    
    if emptySearch {
      return false
    } else {
      let appropriateMLResponses = self.vision.classifications[cloud.title]
      let bestResponse = appropriateMLResponses?.first
      let searchTextContainsResponse = (bestResponse?.1.lowercased() ?? "").contains(searchText.lowercased())
      return (cloud.app.contains(searchText)) == true || (cloud.title.contains(searchText)) == true || searchTextContainsResponse == true
    }
  }
}
