//
//  AppMachine.swift
//  Gilmoyazo
//
//  Created by Markim Shaw on 9/13/20.
//  Copyright © 2020 Markim Shaw. All rights reserved.
//

import Combine
import Foundation

enum AppState {
  case startup
  case onboarding
  case dashboard
  case info
}

enum AppEvent {
  case toOnboarding
  case toDashboard
  case restart
}

class AppMachine: ObservableObject {
  
  // MARK: - Properties -
  
  @Published var state: AppState = .startup
  
  let eventInputPassthrough: PassthroughSubject<AppEvent, Never> = PassthroughSubject<AppEvent, Never>()
  
  private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
  
  init() {
    eventInputPassthrough
      .receive(on: RunLoop.main)
      .flatMap { event -> AnyPublisher<AppState, Never> in
        Future<AppState, Never> { seal in
          let state = self.machine(self.state, event)
          seal(.success(state))
        }.eraseToAnyPublisher()
      }
      .receive(on: RunLoop.main)
      .assign(to: \.state, on: self)
      .store(in: &cancellables)
  }
  
  private func machine(_ state: AppState, _ event: AppEvent) -> AppState{
    
    switch state {
      case .startup:
        switch event {
          case .toOnboarding: return .onboarding
          case .toDashboard: return .dashboard
          default: return .startup
        }
      case .dashboard: return .dashboard
      case .onboarding: return .onboarding
      case .info:
        switch event {
          case .toDashboard: return .dashboard
          case .toOnboarding: return .onboarding
          case .restart: return .startup
        }
    }
  }
}
