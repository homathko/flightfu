//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

enum FFError: LocalizedError {
    case analyzerFailed

    init(_ error: Error) {
        print("NEW FF_ERR ## ## ## ## - \(error.localizedDescription)")
        dump(error)

        self = .analyzerFailed
    }

    var errorDescription: String? {
        switch self {
            case .analyzerFailed:
                return NSLocalizedString(
                        "The sound analyzer failed. Please try relaunching the app",
                        comment: "")
        }
    }
}