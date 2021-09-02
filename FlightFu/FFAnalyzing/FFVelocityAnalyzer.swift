//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation
import Combine

class FFVelocityAnalyzer: FFAnalyzer {
    static let shared = FFVelocityAnalyzer()
    private var service = LocationService.shared
    var cancellables = Set<AnyCancellable>()

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
                self.accuracyIsTolerable = location.speedAccuracy >= 0 && location.speedAccuracy <= 2
            }
        } .store(in: &cancellables)
    }

    override func start (events: FFEventEmitter) {
        super.start(events: events)

        service.$location.sink { location in
            if let location = location {
                if location.speed > 1 {
                    events.send(.brakeRelease)
                } else {
                    events.send(.brakeSet)
                }
            }
        } .store(in: &cancellables)
    }
}