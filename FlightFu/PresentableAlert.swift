//
// Created by Eric Lightfoot on 2021-09-02.
//

import Foundation

struct PresentableAlert: Equatable, Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    var confirmAction: (() -> Void)?
    var confirmLabel: String?
    var dismissAction: (() -> Void)?
    var dismissLabel: String?

    static func == (lhs: PresentableAlert, rhs: PresentableAlert) -> Bool {
        lhs.id == rhs.id
    }
}