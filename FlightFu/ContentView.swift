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
    @State var alert: PresentableAlert?

    var body: some View {
        VStack {
            if app.state.current is FFAppStateIdle { idle }
            else if app.state.current is FFAppStateArmed { armed }
            else if app.state.current is FFAppStateCapturing { capturing }
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
    }

    var armed: some View {
        Button("Disarm") {
            app.disarm()
        }
    }

    var capturing: some View {
        Text("Capturing")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(app: App())
    }
}
