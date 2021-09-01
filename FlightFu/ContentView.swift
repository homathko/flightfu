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

    var body: some View {
        if app.state.current is FFAppStateIdle { idle }
        else if app.state.current is FFAppStateArmed { armed }
        else if app.state.current is FFAppStateCapturing { capturing }
    }

    var idle: some View {
        Button("Arm") {
            app.arm()
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
