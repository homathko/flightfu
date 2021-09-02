//
// Created by Eric Lightfoot on 2020-05-06.
// Copyright (c) 2020 HomathkoTech. All rights reserved.
//

import Foundation
import UIKit.UIApplication
import CoreLocation

/// The level of service available based on
/// permissions given by the user, based on
/// the app function requested
enum LocationServiceLevel {
    /// Service available for velocity only
    case velocityOnly

    /// Service available for background region enter/exit events
    case backgroundRegionMonitoring
}

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    var serviceLevel: LocationServiceLevel = .velocityOnly
    internal var authStatus: CLAuthorizationStatus
    private var locations = [CLLocation]()

    public var heading: CLHeading?

    @Published var location: CLLocation?

    private override init () {
        authStatus = locationManager.authorizationStatus
        super.init()
        locationManager.activityType = .otherNavigation
        locationManager.delegate = self
        _ = start(forServiceLevel: .velocityOnly)
    }

    private func canStartService (forServiceLevel serviceLevel: LocationServiceLevel) -> Bool {
        switch serviceLevel {
            case .velocityOnly:
                return CLLocationManager.locationServicesEnabled() &&
                        (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways)

//            case .accurateFeed:
//                return CLLocationManager.locationServicesEnabled() &&
//                        (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways) &&
//                        locationManager.accuracyAuthorization == CLAccuracyAuthorization.fullAccuracy

            case .backgroundRegionMonitoring:
                return CLLocationManager.locationServicesEnabled() &&
                        authStatus == .authorizedAlways &&
                        locationManager.accuracyAuthorization == CLAccuracyAuthorization.fullAccuracy
        }
    }

    public func start (forServiceLevel serviceLevel: LocationServiceLevel) -> Bool {
        var needsToUpdateSystemSettings: Bool = false
        /// If we can't start this service, whole lotta trouble
        if !canStartService(forServiceLevel: serviceLevel) {
            /// 2 avenues at our disposal
            /// 1)  Request for the needed authorization in-app using
            ///     CLLocationManager API
            if serviceLevel == LocationServiceLevel.velocityOnly {
                if authStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
                } else {
                    needsToUpdateSystemSettings = true
                }
            } else if serviceLevel == LocationServiceLevel.backgroundRegionMonitoring {
                if authStatus == .notDetermined {
                    locationManager.requestWhenInUseAuthorization()
//                locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "PURPOSE_KEY")
                } else {
                    needsToUpdateSystemSettings = true
                }
            } else {
                needsToUpdateSystemSettings = true
            }

            /// 2)  Return false if the caller should handle presenting an
            /// app-wide alert with confirm action that navigates out of the
            /// app to system settings
            if needsToUpdateSystemSettings {
                return false
            }
        }

        /// Update state management
        /// authorization change could happen any time
        self.serviceLevel = serviceLevel

        /// Reduce battery consumption a lot
        locationManager.allowsBackgroundLocationUpdates = self.serviceLevel == .backgroundRegionMonitoring ? true : false

        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        return true
    }

    public func stop () {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authStatus = status
        stop()
        /// TODO If there is an active cycle when the auth changes (edge case)
        /// the recorded flight path will be affected
        _ = start(forServiceLevel: self.serviceLevel)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations = locations
        location = locations.last
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
}
