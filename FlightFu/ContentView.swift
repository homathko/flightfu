//
//  ContentView.swift
//  FlightFu
//
//  Created by Eric Lightfoot on 2021-08-26.
//
//

import SwiftUI

struct ContentView: View {
    @StateObject var app: App
    @ObservedObject var soundAnalyzer = FFSoundAnalyzer.shared
    @ObservedObject var velocityAnalyzer = FFVelocityAnalyzer.shared
    
    @State var alert: PresentableAlert?

    var body: some View {
        VStack {
            ///
            /// Flight state
            ///
            VStack {
                Text(flightState).font(.system(size: 24))
            }
            ///
            /// Key metrics
            ///
            VStack {
                HStack {
                    KeyMetricView(
                        name: "Engine",
                        value: soundAnalyzer.classificationIdentifier,
                        unit: ""
                    )
                    KeyMetricView(
                        name: "Confidence",
                        value: soundAnalyzer.confidence,
                        unit: "%"
                    )
                }
                HStack {
                    KeyMetricView(
                        name: "Brakes",
                        value: velocityAnalyzer.brakeState,
                        unit: ""
                    )
                    KeyMetricView(
                        name: "Accuracy",
                        value: velocityAnalyzer.accuracy,
                        unit: "m"
                    )
                }
            }
            
            ///
            /// Action button
            ///
            VStack {
                if app.state.current is FFAppStateIdle { idle }
                else if app.state.current is FFAppStateArmed { armed }
                else if app.state.current is FFAppStateCapturing { capturing }
            }
        }

        ///
        /// Alert UI
        ///
                .alert(item: $alert) { alert in
                    let alert = alert as PresentableAlert
                    return Alert(
                            title: Text(alert.title),
                            message: Text(alert.message ?? "..."),
                            primaryButton: .default(Text(alert.confirmLabel ?? "Confirm")) {
                                alert.confirmAction?()
                            },
                            secondaryButton: .cancel(Text(alert.dismissLabel ?? "Cancel")) {
                                alert.dismissAction?()
                            }
                    )
                }
                .onReceive(app.$alert) { alert in
                    self.alert = alert
                }
    }

    var idle: some View {
        Button("Arm") {
            if app.locationService.start(forServiceLevel: .velocityOnly) {
                app.arm()
            } else {
                app.alert = PresentableAlert(
                        title: "Location required",
                        message: """
                                 FlightFu needs permission to access your location information so that it can sense your velocity. Selecting
                                 1) Just this once
                                 2) When in use, or
                                 3) Always
                                 will work
                                 """,
                        confirmAction: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            app.alert = nil
                        },
                        confirmLabel: "Settings",
                        dismissAction: {
                            app.alert = nil
                        },
                        dismissLabel: "No thanks"
                )
            }
        }
                .buttonStyle(MyButtonStyle())
    }

    var armed: some View {
        Button("Disarm") {
            app.disarm()
        }
                .buttonStyle(MyButtonStyle())
    }

    var capturing: some View {
        Text("Capturing")
    }

    var flightState: String {
        if let state = app.state.current as? FFAppStateCapturing {
            if let velocity = state.velocity,
            let engine = state.engine {
                switch (velocity, engine) {
                    case (is FFVelocityStateStationary, is FFEngineStateSecure): return ""
                    case (is FFVelocityStateStationary, is FFEngineStateRunning): return "Idling"
                    case (is FFVelocityStateRolling, is FFEngineStateSecure): return "NOT good"
                    case (is FFVelocityStateRolling, is FFEngineStateRunning): return "Taxiing"
                    case (is FFVelocityStateAirborne, is FFEngineStateSecure): return "Gliding"
                    case (is FFVelocityStateAirborne, is FFEngineStateRunning): return "Flying"
                    default: return "No match"
                }
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(app: App())
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(red: 1.0, green: 0, blue: 0))
            .opacity(0.8)
            .foregroundColor(.white)
            .font(.title2)
    }
}
