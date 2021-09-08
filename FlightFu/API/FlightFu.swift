//
// Created by Eric Lightfoot on 2021-09-06.
//
import Foundation
import Combine
import CoreLocation

/// FlightFu is an experimental API that publishes aircraft
/// flight state changes. It leverages the Sound Analysis
/// framework to determine if audio signal from the device
/// microphone sounds like an aircraft engine "running".
/// The ML model included with the package was trained with
/// ~25 audio recordings of C172, C182, and C185 aircraft
/// taken from the cockpit position with an iPhone.

/// "System" states of the API
enum FlightFuSystemState {
    case idle, armed, capturing
}

/// "Flight" states, which are sub states mutual to the Armed
/// and Capturing system states
enum FlightFuFlightState: String {
    case secure, idling, taxiing, airborne, gliding
}

final class FlightFu {
    public var state: FFState {
        stateMachine.currentState as? FFState ?? FFAppStateIdle()
    }

    private var stateMachine: FFStateMachine
    private var systemStateSubject = CurrentValueSubject<FlightFuSystemState, FFError>(.idle)
    private var flightStateSubject = CurrentValueSubject<FlightFuFlightState, FFError>(.secure)
    private var locationService = LocationService.shared
    private var events = FFAppEventEmitter()
    private var cancellables = Set<AnyCancellable>()
    private var flightStateCancellable: AnyCancellable?

    init () {
        /// Configure event driven app state
        stateMachine = FFStateMachine(states: events.wiredAppStates())

        // System state can be idle, armed or capturing
        stateMachine.publisher().sink(receiveCompletion: { completion in
            switch completion {
                case .finished: assert(false, "This should never happen")
                case .failure(let error): ()
                    // TODO Implement error handling
            }
        }, receiveValue: { newState in
            // Stop listening to previous state substate events
            self.flightStateCancellable?.cancel()
            self.flightStateCancellable = nil

            print(self.state)
            switch newState {
                case is FFAppStateIdle:
                    self.systemStateSubject.send(.idle)
                case is FFAppStateArmed:
                    if let eventful = newState as? FFStateEventful {
                        self.flightStateCancellable = eventful.events.publisher.sink { event in
                            self.flightStateSubject.send(self.flightState)
                        }
                        self.systemStateSubject.send(.armed)
                    }
                case is FFAppStateCapturing:
                    if let eventful = newState as? FFStateEventful {
                        self.flightStateCancellable = eventful.events.publisher.sink { event in
                            self.flightStateSubject.send(self.flightState)
                        }
                        self.systemStateSubject.send(.capturing)
                    }
                default: ()
            }
        }).store(in: &cancellables)

        /// Set the machine in motion
        stateMachine.enter(FFAppStateIdle.self)
    }

    // Instantaneous flight state 😎
    public var flightState: FlightFuFlightState {
        if let state = stateMachine.currentState as? FFAppStateArmed {
            if let velocity = state.velocity,
               let engine = state.engine {
                switch (velocity, engine) {
                    case (is FFVelocityStateStationary, is FFEngineStateSecure): return .secure
                    case (is FFVelocityStateStationary, is FFEngineStateRunning): return .idling
                    case (is FFVelocityStateRolling, is FFEngineStateSecure): return .taxiing
                    case (is FFVelocityStateRolling, is FFEngineStateRunning): return .taxiing
                    case (is FFVelocityStateAirborne, is FFEngineStateSecure): return .airborne
                    case (is FFVelocityStateAirborne, is FFEngineStateRunning): return .airborne
                    default: return .secure
                }
            } else {
                return .secure
            }
        } else if let state = stateMachine.currentState as? FFAppStateCapturing {
            if let velocity = state.velocity,
               let engine = state.engine {
                switch (velocity, engine) {
                    case (is FFVelocityStateStationary, is FFEngineStateSecure): return .secure
                    case (is FFVelocityStateStationary, is FFEngineStateRunning): return .idling
                    case (is FFVelocityStateRolling, is FFEngineStateSecure): return .taxiing
                    case (is FFVelocityStateRolling, is FFEngineStateRunning): return .taxiing
                    case (is FFVelocityStateAirborne, is FFEngineStateSecure): return .airborne
                    case (is FFVelocityStateAirborne, is FFEngineStateRunning): return .airborne
                    default: return .secure
                }
            } else {
                return .secure
            }
        } else {
            return .secure
        }
    }

    public func arm () {
        events.send(.beginSensing)
    }

    public func disarm () {
        events.send(.endSensing)
    }

    public func systemStatePublisher () -> AnyPublisher<FlightFuSystemState, FFError> {
        systemStateSubject.share().eraseToAnyPublisher()
    }

    public func flightStatePublisher () -> AnyPublisher<FlightFuFlightState, FFError> {
        flightStateSubject.share().eraseToAnyPublisher()
    }
}
