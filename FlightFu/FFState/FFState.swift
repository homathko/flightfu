//
// Created by Eric Lightfoot on 2021-08-26.
//

import GameplayKit
import Combine

class FFStateMachine: GKStateMachine, ObservableObject {
    @Published var current: FFState?
}

class FFState: GKState {
    override func didEnter (from previousState: GKState?) {
        super.didEnter(from: previousState)
        if let wrappingStateMachine = stateMachine as? FFStateMachine {
            wrappingStateMachine.current = stateMachine?.currentState as? FFState
        }
    }

    override func willExit (to nextState: GKState) {
        super.willExit(to: nextState)

//        print("\(self) \(#function): \(stateMachine == nil ? "N/A": stateMachine!.currentState.debugDescription) --> \(nextState)")
    }
}