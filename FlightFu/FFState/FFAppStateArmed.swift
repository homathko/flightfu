//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit
///
/// Armed state had a nested state machine to monitor
/// for flight events as well as system events
class FFAppStateArmed: FFState {
    private var events = FFArmedEventEmitter()
    private var engineState: FFStateMachine?
    private var velocityState: FFStateMachine?
    private var engineAnalyzer: FFSoundAnalyzerMock
    private var velocityAnalyzer: FFVelocityAnalyzer

    override init () {
        engineState = FFStateMachine(states: events.wiredArmedEngineSubStates())
        velocityState = FFStateMachine(states: events.wiredArmedVelocitySubStates())
        engineAnalyzer = FFSoundAnalyzerMock.shared
        velocityAnalyzer = FFVelocityAnalyzer.shared
        engineAnalyzer.start(events: events)
        velocityAnalyzer.start(events: events)
        super.init()
    }

    override func isValidNextState (_ stateClass: AnyClass) -> Bool {
        stateClass == FFAppStateCapturing.self ||
        stateClass == FFAppStateIdle.self
    }

    override func didEnter (from previousState: GKState?) {
        super.didEnter(from: previousState)
        engineState!.enter(FFEngineStateSecure.self)
        velocityState!.enter(FFVelocityStateStationary.self)
        engineAnalyzer.testForArmedState()
    }

    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)
        print("leaving armed state for capturing state")
    }

    func checkForCapturingState () {
        if stateMachine?.currentState == self {
            if engineState?.current is FFEngineStateRunning &&
                       velocityState?.current is FFVelocityStateRolling {
                stateMachine?.enter(FFAppStateCapturing.self)
            }
        }
    }

    /// Transitions
    func error (_ event: FFEvent) {

    }

    func beginCapture () {

    }

    func endSensing () {
        stateMachine?.enter(FFAppStateIdle.self)
    }

    // TODO disconnect event subscribers on exit from this state
}