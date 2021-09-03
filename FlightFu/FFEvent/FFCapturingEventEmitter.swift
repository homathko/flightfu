//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import UIKit
import Combine
import GameplayKit

class FFCapturingEventEmitter: FFEventEmitter {

    public func wiredCapturingEngineSubStates () -> [FFState] {
        let engineRunning = FFEngineStateRunning()
        let engineSecure = FFEngineStateSecure()

        /// Engine running state
        assign(event: .engineStop) { _ in engineRunning.engineStop() }
        /// Engine secure state
        assign(event: .engineStart) { _ in engineSecure.engineStart() }

        return [engineRunning, engineSecure]
    }

    public func wiredCapturingVelocitySubStates () -> [FFState] {
        let velocityAirborne = FFVelocityStateAirborne()
        let velocityRolling = FFVelocityStateRolling()
        let velocityStationary = FFVelocityStateStationary()

        /// Velocity airborne state
        assign(event: .wheelsDown) { _ in velocityAirborne.wheelsDown() }
        /// Velocity stationary state
        assign(event: .brakeRelease) { _ in velocityStationary.brakeRelease() }
        /// Velocity rolling state
        assign(event: .brakeSet) { _ in velocityRolling.brakeSet() }
        assign(event: .wheelsUp) { _ in velocityRolling.wheelsUp() }

        return [velocityStationary, velocityRolling, velocityAirborne]
    }
}
