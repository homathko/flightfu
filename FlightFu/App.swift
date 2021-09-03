//
// Created by Eric Lightfoot on 2021-08-26.
//

import Foundation
import Combine
import SwiftUI

class App: ObservableObject {
    @ObservedObject var state: FFStateMachine
    @Published var alert: PresentableAlert?

    public var locationService = LocationService.shared
    private var events = FFAppEventEmitter()
    private var cancellables = Set<AnyCancellable>()

    init () {
        /// Configure event driven app state
        state = FFStateMachine(states: events.wiredAppStates())
        /// Set the machine in motion
        state.enter(FFAppStateIdle.self)

        state.$current.receive(on: DispatchQueue.main).sink { newState in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }

    func arm () {
        events.send(.beginSensing)
    }

    func disarm () {
        events.send(.endSensing)
    }
}