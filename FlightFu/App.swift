//
// Created by Eric Lightfoot on 2021-08-26.
//

import Foundation
import Combine
import SwiftUI

class App: ObservableObject {
    public var flightfu = FlightFu()
    public var locationService = LocationService.shared

    @Published var systemState: FlightFuSystemState = .idle
    @Published var flightState: FlightFuFlightState = .secure
    @Published var alert: PresentableAlert?

    private var cancellables = Set<AnyCancellable>()

    init () {
        flightfu.flightStatePublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished: ()
                        case .failure(let error): print(error.errorDescription ?? "N/A")
                    }
                }, receiveValue: { state in
                    print("Flight state changed to: \(state)")
                    self.flightState = state
                }).store(in: &cancellables)

        flightfu.systemStatePublisher()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished: ()
                        case .failure(let error): print(error.errorDescription ?? "N/A")
                    }
                }, receiveValue: { state in
                    print("System state changed to \(state)")
                    self.systemState = state
                }).store(in: &cancellables)
    }
}