//
//  FlightFuTestApp.swift
//  FlightFu
//
//  Created by Eric Lightfoot on 2021-08-26.
//
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    let app = App()
}

@main
struct FlightFuTestApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appDelegate.app)
        }
    }
}
