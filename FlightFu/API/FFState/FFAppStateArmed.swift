//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation
import GameplayKit
///
/// Armed state has nested state machines to monitor
/// for flight events
class FFAppStateArmed: FFState, FFStateEventful {
    private var _events = FFArmedEventEmitter()
    private var engineState: FFStateMachine?
    private var velocityState: FFStateMachine?
#if targetEnvironment(simulator)
    private var engineAnalyzer: FFSoundAnalyzerMock
#else
    private var engineAnalyzer: FFSoundAnalyzer
#endif
    private var velocityAnalyzer: FFVelocityAnalyzer

    override init () {
        engineState = FFStateMachine(states: _events.wiredArmedEngineSubStates())
        velocityState = FFStateMachine(states: _events.wiredArmedVelocitySubStates())
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
        stateClass == FFAppStateCapturing.self ||
        stateClass == FFAppStateIdle.self
    }

    override func didEnter (from previousState: GKState?) {
        super.didEnter(from: previousState)
        engineState!.enter(FFEngineStateSecure.self)
        velocityState!.enter(FFVelocityStateStationary.self)
    #if targetEnvironment(simulator)
        engineAnalyzer.testForArmedState()
    #endif
    }

    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)
    }

    func checkForCapturingState () {
        if stateMachine?.currentState == self {
            if engineState?.currentState is FFEngineStateRunning &&
               velocityState?.currentState is FFVelocityStateRolling {
                    beginCapture()
            }
        }
    }

    var events: FFEventEmitter {
        _events
    }

    /// Transitions
    func error (_ event: FFEvent) {

    }

    func beginCapture () {
        stateMachine?.enter(FFAppStateCapturing.self)
    }

    func endSensing () {
        stateMachine?.enter(FFAppStateIdle.self)
    }
}

extension FFAppStateArmed {
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
