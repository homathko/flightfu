//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation
import Combine

enum FFVelocityAnalyzerBrakeState {
    case brakeSet, brakeRelease
}
class FFVelocityAnalyzer: FFAnalyzer, ObservableObject {
    static let shared = FFVelocityAnalyzer()
    
    @Published var brakeState: FFVelocityAnalyzerBrakeState = .brakeSet
    @Published var accuracy: Double = 100
    
    private var service = LocationService.shared
    private var cancellables = Set<AnyCancellable>()

    /// AppStateArmed logic will stop waiting for brakeRelease
    /// event if speed accuracy is intolerable at the time the
    /// engineStart event is received
    public var accuracyIsTolerable = false

    private override init () {
        super.init()
        /// Set up speed accuracy monitor
        service.publisher.sink(receiveCompletion: { completion in
            switch completion {
                case .finished: assert(false, "This can't happen")
                case .failure(let error): ()
                    // TODO implement
            }
        }, receiveValue: { value in
            if let location = value {
                /// Negative values indicate invalid values
                self.accuracy = location.speedAccuracy
            }
        }).store(in: &cancellables)
    }

    override func start (events: FFEventEmitter) {
        super.start(events: events)

        service.publisher.sink(receiveCompletion: { completion in
            switch completion {
                case .finished: assert(false, "This can't happen")
                case .failure(let error): ()
                    // TODO implement
            }
        }, receiveValue: { value in
            if let location = value {
                if (1..<20).contains(location.speed.knots) {
                    events.send(.brakeRelease)
                    events.send(.wheelsDown)

                    if self.brakeState != .brakeRelease {
                        self.brakeState = .brakeRelease
                    }
                } else if location.speed.knots >= 20 {
                    events.send(.wheelsUp)
                } else {
                    events.send(.brakeSet)
                    
                    if self.brakeState != .brakeSet {
                        self.brakeState = .brakeSet
                    }
                }
            }
        }).store(in: &cancellables)
    }
}
