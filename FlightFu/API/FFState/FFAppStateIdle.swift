//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit
///
/// FFStateIdle
///
/// The Idle state is so far quite different from the others
/// in that it must be ready to accept entries from every
/// other state, and is also the initial pseudo state
///

class FFAppStateIdle: FFState {
    /// Transitions
    func beginSensing () {
        stateMachine?.enter(FFAppStateArmed.self)
    }

    func terminate (_ event: FFEvent) {

    }

    override func isValidNextState (_ stateClass: AnyClass) -> Bool {
        stateClass == FFAppStateArmed.self
    }
}