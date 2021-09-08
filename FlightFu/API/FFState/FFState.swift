//
// Created by Eric Lightfoot on 2021-08-26.
//

import GameplayKit
import Combine

/// FFStateMachine wraps GKStateMachine to provide
/// a publisher which emits FFState types when its
/// own state changes
class FFStateMachine: GKStateMachine {
    private var currentSubject = CurrentValueSubject<FFState, FFError>(FFAppStateIdle())

    public func publisher () -> AnyPublisher<FFState, FFError> {
        currentSubject.share().eraseToAnyPublisher()
    }

    public func send (_ state: FFState?) {
        if let state = state {
            currentSubject.send(state)
        } else {
            currentSubject.send(FFAppStateIdle())
        }
    }
}

class FFState: GKState {
    ///
    /// didEnter
    ///
    /// This method is used to hand off the current state to a
    /// @Published mirroring property to allow SwiftUI to react
    /// to value changes
    ///
    /// NOTE: All subclasses that implement didEnter must call
    /// super or SwiftUI will not notice the change
    ///
    /// - Parameter previousState: unused
    override func didEnter (from previousState: GKState?) {
        super.didEnter(from: previousState)
        if let wrappingStateMachine = stateMachine as? FFStateMachine {
            wrappingStateMachine.send(stateMachine?.currentState as? FFState)
        }
    }

    /// Logging hook
    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)

        // Logging disabled
//        print("\(self) \(#function): \(stateMachine == nil ? "N/A": stateMachine!.currentState.debugDescription) --> \(nextState)")
    }
}

protocol FFStateEventful {
    var events: FFEventEmitter { get }
}