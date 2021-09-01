//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

class FFVelocityAnalyzerMock {
    static let shared = FFVelocityAnalyzerMock()
    var events: [FFEventEmitter] = []

    private init () { }

    func start (events: FFEventEmitter) {
        self.events.append(events)
    }

    func testForArmedState () {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.isRolling()
        }
    }

    func testForCapturingState () {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.deadStopped()
        }
    }

    private func deadStopped () {
        events.forEach { $0.send(.brakeSet) }
    }

    private func isRolling () {
        events.forEach { $0.send(.brakeRelease) }
    }

    private func isWheelsUp () {
        events.forEach { $0.send(.wheelsUp) }
    }

    private func isWheelsDown () {
        events.forEach { $0.send(.wheelsDown) }
    }

    func kill (forEvents events: FFEventEmitter) {
        if let index = self.events.firstIndex(where: { $0 === events }) {
            self.events[index].kill()
            self.events.remove(at: index)
        }
    }
}