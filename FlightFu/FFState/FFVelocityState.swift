//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit

class FFVelocityStateStationary: FFState {
    /// Transitions
    func brakeRelease () {
        stateMachine?.enter(FFVelocityStateRolling.self)
    }
}

class FFVelocityStateRolling: FFState {
    /// Transitions
    func brakeSet () {
        stateMachine?.enter(FFVelocityStateStationary.self)
    }

    func wheelsUp () {
        stateMachine?.enter(FFVelocityStateAirborne.self)
    }
}

class FFVelocityStateAirborne: FFState {
    /// Transitions
    func wheelsDown () {
        stateMachine?.enter(FFVelocityStateRolling.self)
    }
}