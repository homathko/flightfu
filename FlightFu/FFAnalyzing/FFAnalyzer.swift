//
// Created by Eric Lightfoot on 2021-08-27.
//

import Foundation

open class FFAnalyzer {
    var events: [FFEventEmitter] = []

    internal init () { }

    func start (events: FFEventEmitter) {
        self.events.append(events)
    }

    func kill (forEvents events: FFEventEmitter) {
        if let index = self.events.firstIndex(where: { $0 === events }) {
            self.events[index].kill()
            self.events.remove(at: index)
        }
    }
}