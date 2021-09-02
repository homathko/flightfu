//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

class FFVelocityAnalyzerMock: FFAnalyzer {
    static let shared = FFVelocityAnalyzerMock()

    private override init () { }

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
}