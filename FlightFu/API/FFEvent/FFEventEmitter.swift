//
// Created by Eric Lightfoot on 2021-08-26.
//

import Foundation
import UIKit
import Combine

class FFEventEmitter {
    private var subject = PassthroughSubject<FFEvent, Never>()
    var cancellables = Set<AnyCancellable>()

    init () {
        /// Create the subject for the app
        subject = PassthroughSubject<FFEvent, Never>()
    }

    public var publisher: AnyPublisher<FFEvent, Never> {
        subject.share().eraseToAnyPublisher()
    }

    internal func publisher (for event: FFEvent) -> AnyPublisher<FFEvent, Never> {
        subject.share().filter { e in
            event == e
        }.eraseToAnyPublisher()
    }

    internal func assign (event: FFEvent, _ toBlock: @escaping (FFEvent) -> ()) {
        publisher(for: event).sink(receiveValue: toBlock).store(in: &cancellables)
    }

    public func send (_ event: FFEvent) {
        if event != .tick {
            print("\(self) \(#function): \(event)")
        }
        subject.send(event)
    }

    public func kill () {
        cancellables.forEach { $0.cancel() }
    }
}
