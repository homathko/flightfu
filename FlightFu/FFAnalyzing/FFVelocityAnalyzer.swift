//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation
import Combine

class FFVelocityAnalyzer: FFAnalyzer, ObservableObject {
    static let shared = FFVelocityAnalyzer()
    
    @Published var brakeState: String = ""
    @Published var accuracy: String = ""
    
    private var service = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    /// AppStateArmed logic will stop waiting for brakeRelease
    /// event if speed accuracy is intolerable at the time the
    /// engineStart event is received
    public var accuracyIsTolerable = false

    private override init () {
        super.init()
        /// Set up speed accuracy monitor
        service.$location.sink { location in
            if let location = location {
                /// Negative values indicate invalid values
                let goodEnough = location.speedAccuracy >= 0 && location.speedAccuracy <= 2
                self.accuracyIsTolerable = goodEnough
                self.accuracy = String(format: "%0.1f", location.speedAccuracy)
            }
        } .store(in: &cancellables)
    }

    override func start (events: FFEventEmitter) {
        super.start(events: events)

        service.$location.sink { location in
            if let location = location {
                if (1..<20).contains(location.speed.knots) {
                    events.send(.brakeRelease)
                    events.send(.wheelsDown)

                    if self.brakeState != "release" {
                        self.brakeState = "release"
                    }
                } else if location.speed.knots >= 20 {
                    events.send(.wheelsUp)
                } else {
                    events.send(.brakeSet)
                    
                    if self.brakeState != "set" {
                        self.brakeState = "set"
                    }
                }
            }
        } .store(in: &cancellables)
    }
}
