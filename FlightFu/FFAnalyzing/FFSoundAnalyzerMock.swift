//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import Combine

class FFSoundAnalyzerMock: FFAnalyzer, ObservableObject {
    static let shared = FFSoundAnalyzerMock()

    @Published var error: Error?
    @Published var classificationIdentifier: String = ""
    @Published var confidence: String = "mock"

    private override init () {
        super.init()
    }

    func testForArmedState () {
        DispatchQueue.main.async {
            self.classificationIdentifier = "secure"
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.engineStarted()
        }
    }

    func testForCapturingState () {
        DispatchQueue.main.async {
            self.classificationIdentifier = "running"
        }
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] timer in
            timer.invalidate()
            self?.engineStopped()
        }
    }

    func engineStarted () {
        DispatchQueue.main.async {
            self.classificationIdentifier = "running"
        }
        events.forEach { $0.send(.engineStart) }
    }

    func engineStopped () {
        DispatchQueue.main.async {
            self.classificationIdentifier = "secure"
        }
        events.forEach { $0.send(.engineStop)}
    }
}