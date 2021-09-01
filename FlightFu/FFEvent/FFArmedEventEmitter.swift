//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import UIKit
import Combine
import GameplayKit

class FFArmedEventEmitter: FFEventEmitter {

    public func wiredArmedEngineSubStates () -> [FFState] {
        let engineSecure = FFEngineStateSecure()
        let engineRunning = FFEngineStateRunning()

        /// Engine secure state
        assign(event: .engineStart) { _ in engineSecure.engineStart() }
        /// Engine running state
        assign(event: .engineStop) { _ in engineRunning.engineStop() }

        return [engineSecure, engineRunning]
    }

    public func wiredArmedVelocitySubStates () -> [FFState] {
        let velocityStationary = FFVelocityStateStationary()
        let velocityRolling = FFVelocityStateRolling()

        /// Velocity stationary state
        assign(event: .brakeRelease) { _ in velocityStationary.brakeRelease() }
        /// Velocity rolling state
        assign(event: .brakeSet) { _ in velocityRolling.brakeSet() }

        return [velocityStationary, velocityRolling]
    }
}

