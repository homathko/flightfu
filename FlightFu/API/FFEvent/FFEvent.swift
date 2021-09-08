//
// Created by Eric Lightfoot on 2021-08-27.
//

enum FFEvent: Equatable {
    static func == (lhs: FFEvent, rhs: FFEvent) -> Bool {
        switch (lhs, rhs) {
            case (.launchedByUser, .launchedByUser): return true
            case (.launchedByLocation, .launchedByLocation): return true
            case (.beginSensing, .beginSensing): return true
            case (.beginCapture, .beginCapture): return true
            case (.tick, .tick): return true
            case (.error(let lh), .error(let rh)): return true
            case (.endSensing, .endSensing): return true
            case (.endCapture, .endCapture): return true
            case (.terminate, .terminate): return true
            case (.engineStart, .engineStart): return true
            case (.engineStop, .engineStop): return true
            case (.brakeRelease, .brakeRelease): return true
            case (.brakeSet, .brakeSet): return true
            case (.wheelsUp, .wheelsUp): return true
            case (.wheelsDown, .wheelsDown): return true
            default: return false
        }
    }

    case launchedByUser,
         launchedByLocation,
         beginSensing,
         beginCapture,
         tick,
         error(FFError),
         endSensing,
         endCapture,
         terminate,
         engineStart,
         engineStop,
         brakeRelease,
         brakeSet,
         wheelsUp,
         wheelsDown
}