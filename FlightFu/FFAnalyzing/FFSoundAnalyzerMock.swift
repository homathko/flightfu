//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

class FFSoundAnalyzerMock {
    static let shared = FFSoundAnalyzerMock()
    private var events: [FFEventEmitter] = []

    private init () { }

    func start (events: FFEventEmitter) {
        self.events.append(events)
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

    func kill (forEvents events: FFEventEmitter) {
        if let index = self.events.firstIndex(where: { $0 === events }) {
            self.events[index].kill()
            self.events.remove(at: index)
        }
    }
}