//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit

class FFAppStateCapturing: FFState {
    private var events = FFCapturingEventEmitter()
    private var engineState: FFStateMachine?
    private var velocityState: FFStateMachine?
    private var engineAnalyzer: FFSoundAnalyzerMock
    private var velocityAnalyzer: FFVelocityAnalyzerMock

    override init () {
        engineState = FFStateMachine(states: events.wiredCapturingEngineSubStates())
        velocityState = FFStateMachine(states: events.wiredCapturingVelocitySubStates())
        engineAnalyzer = FFSoundAnalyzerMock.shared
        velocityAnalyzer = FFVelocityAnalyzerMock.shared
        engineAnalyzer.start(events: events)
        velocityAnalyzer.start(events: events)
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
        engineAnalyzer.testForCapturingState()
        velocityAnalyzer.testForCapturingState()
    }

    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)
        print("leaving capturing state for idle state")
    }

    func checkForIdleState () {
        if stateMachine?.currentState == self {
            if engineState?.current is FFEngineStateSecure &&
                       velocityState?.current is FFVelocityStateStationary {
                stateMachine?.enter(FFAppStateIdle.self)
            }
        }
    }

    func endCapture (_ event: FFEvent) {

    }

    // TODO disconnect event subscribers on exit from this state
}