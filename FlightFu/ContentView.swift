//
//  ContentView.swift
//  FlightFu
//
//  Created by Eric Lightfoot on 2021-08-26.
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: App
    
    @State var alert: PresentableAlert?

    var body: some View {
        VStack {
            ///
            /// System state
            ///
            VStack {
                HStack {
                    KeyMetricView(
                            name: "System",
                            value: "\(app.systemState)",
                            unit: ""
                    )
                }
            }

            ///
            /// Action button
            ///
            VStack {
                if app.flightfu.state is FFAppStateIdle { idle }
                else if app.flightfu.state is FFAppStateArmed { armed }
                else if app.flightfu.state is FFAppStateCapturing { capturing }
            }

            ///
            /// Flight state
            ///
            VStack {
                HStack {
                    KeyMetricView(
                            name: "Flight State",
                            value: "\(app.flightState)",
                            unit: ""
                    )
                }
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
                app.flightfu.arm()
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
            app.flightfu.disarm()
        }
                .buttonStyle(MyButtonStyle())
    }

    var capturing: some View {
        Text("Capturing")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(App())
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
