//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

class FFSoundAnalyzerMock: FFAnalyzer {
    static let shared = FFSoundAnalyzerMock()

    private override init () {
        super.init()
    }

    func testForArmedState () {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.engineStarted()
        }
    }

    func testForCapturingState () {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.engineStopped()
        }
    }

    func engineStarted () {
        events.forEach { $0.send(.engineStart) }
    }

    func engineStopped () {
        events.forEach { $0.send(.engineStop)}
    }
}