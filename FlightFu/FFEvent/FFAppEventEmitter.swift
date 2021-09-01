//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import UIKit
import Combine
import GameplayKit

class FFAppEventEmitter: FFEventEmitter {
    override init () {
        super.init()
        /// Create the subject for the app
        publisher = PassthroughSubject<FFEvent, Never>()

        /// Listen for a few important signals from the system
        NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification).sink { notification in
            /// If it is the user who launched, send .launchedByUser event
            if notification.userInfo == nil {
                self.send(.launchedByUser)
            } else {
                /// If it is a location based launch, send .launchedByLocation
                fatalError("userInfo not nil on launch! Implement location-based launch now 👍")
            }
        }.store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification).sink { notification in
            dump(notification.userInfo)
            /// Send .terminate event
            self.send(.terminate)
            /// If app state is sensing or capturing, enqueue a system notification
            /// to alert the user after termination
        }.store(in: &cancellables)

        /// Create timer publisher for the app
        Timer.publish(every: 1.0, on: .main, in: .default).autoconnect().sink { timestamp in
            self.send(.tick)
        }.store(in: &cancellables)
    }

    public func wiredAppStates () -> [GKState] {
        let idle = FFAppStateIdle()

        /// Nested state machine
        let armed = FFAppStateArmed()

        /// Nested state machine
        let capturing = FFAppStateCapturing()

        /// Idle state transitions
        assign(event: .beginSensing) { _ in idle.beginSensing() }
        assign(event: .terminate) { event in idle.terminate(event) }
        /// Armed state transitions
        assign(event: .error(.none)) { event in armed.error(event) }
        assign(event: .beginCapture) { event in armed.beginCapture() }
        assign(event: .endSensing) { event in armed.endSensing() }
        assign(event: .tick) { event in armed.checkForCapturingState() }
        /// Capturing state transitions
        assign(event: .error(.none)) { event in capturing.error(event) }
        assign(event: .tick) { event in capturing.checkForIdleState() }
        assign(event: .endCapture) { event in capturing.endCapture(event) }

        return [idle, armed, capturing]
    }
}
