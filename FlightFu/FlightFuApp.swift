//
//  FlightFuApp.swift
//  FlightFu
//
//  Created by Eric Lightfoot on 2021-08-26.
//
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    let appState = App()
}

@main
struct FlightFuApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(app: appDelegate.appState)
        }
    }
}
