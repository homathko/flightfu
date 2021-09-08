//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit

class FFAppStateCapturing: FFState, FFStateEventful {
    private var _events = FFCapturingEventEmitter()
    private var engineState: FFStateMachine?
    private var velocityState: FFStateMachine?
#if targetEnvironment(simulator)
    private var engineAnalyzer: FFSoundAnalyzerMock
#else
    private var engineAnalyzer: FFSoundAnalyzer
#endif
    private var velocityAnalyzer: FFVelocityAnalyzer

    override init () {
        engineState = FFStateMachine(states: _events.wiredCapturingEngineSubStates())
        velocityState = FFStateMachine(states: _events.wiredCapturingVelocitySubStates())
    #if targetEnvironment(simulator)
        engineAnalyzer = FFSoundAnalyzerMock.shared
    #else
        engineAnalyzer = FFSoundAnalyzer.shared
    #endif
        velocityAnalyzer = FFVelocityAnalyzer.shared
        engineAnalyzer.start(events: _events)
        velocityAnalyzer.start(events: _events)
        super.init()
    }

    override func isValidNextState (_ stateClass: AnyClass) -> Bool {
        stateClass == FFAppStateIdle.self
    }

    /// Transitions
    func error (_ event: FFEvent) {

    }

    override func didEnter (from previousState: GKState?) {
        super.didEnter(from: previousState)
        engineState?.enter(FFEngineStateRunning.self)
        velocityState?.enter(FFVelocityStateRolling.self)
    #if targetEnvironment(simulator)
        engineAnalyzer.testForCapturingState()
    #endif
    }

    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)
        print("leaving capturing state for idle state")
    }

    func checkForSecureState () {
        if stateMachine?.currentState == self {
            if engineState?.currentState is FFEngineStateSecure &&
                       velocityState?.currentState is FFVelocityStateStationary {
                stateMachine?.enter(FFAppStateIdle.self)
            }
        }
    }

    var events: FFEventEmitter {
        _events
    }

    /// Transitions
    func endCapture (_ event: FFEvent) {

    }
}

extension FFAppStateCapturing {
    public var velocity: FFState? {
        velocityState?.currentState as? FFVelocityStateStationary ??
                velocityState?.currentState as? FFVelocityStateRolling ??
                velocityState?.currentState as? FFVelocityStateAirborne
    }

    public var engine: FFState? {
        engineState?.currentState as? FFEngineStateSecure ??
                engineState?.currentState as? FFEngineStateRunning
    }
}
