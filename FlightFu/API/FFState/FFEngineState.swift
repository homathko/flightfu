//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit

class FFEngineStateSecure: FFState {
    /// Transitions
    func engineStart () {
        stateMachine!.enter(FFEngineStateRunning.self)
    }
}

class FFEngineStateRunning: FFState {
    /// Transitions
    func engineStop () {
        stateMachine?.enter(FFEngineStateSecure.self)
    }
}