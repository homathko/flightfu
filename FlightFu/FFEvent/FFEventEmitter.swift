//
// Created by Eric Lightfoot on 2021-08-26.
//

import Foundation
import UIKit
import Combine

class FFEventEmitter {
    public var publisher: PassthroughSubject<FFEvent, Never>?
    var cancellables = Set<AnyCancellable>()

    init () {
        /// Create the subject for the app
        publisher = PassthroughSubject<FFEvent, Never>()
    }

    internal func publisher (for event: FFEvent) -> AnyPublisher<FFEvent, Never> {
        guard publisher != nil else {
            return PassthroughSubject<FFEvent, Never>().eraseToAnyPublisher()
        }

        return publisher!.filter { e in
            event == e
        }.eraseToAnyPublisher()
    }

    internal func assign (event: FFEvent, _ toBlock: @escaping (FFEvent) -> ()) {
        publisher(for: event).sink(receiveValue: toBlock).store(in: &cancellables)
    }

    public func send (_ event: FFEvent) {
        print("\(self) \(#function): \(event)")
        publisher?.send(event)
    }

    public func kill () {
        cancellables.forEach { $0.cancel() }
        publisher = nil
    }

    deinit {
        print("\(self) \(#function)")
    }
}
