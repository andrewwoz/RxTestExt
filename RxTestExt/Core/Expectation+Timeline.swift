import Foundation
import RxSwift
import RxTest

extension Expectation {
    func matchTimeline(_ expectedEvents: [Recorded<Event<Element>>], predicate: (Event<Element>, Event<Element>) -> Bool) {
        evaluate { actualEvents in
            let match = actualEvents.elementsEqual(expectedEvents) { actual, expected in
                actual.time == expected.time
                    && predicate(actual.value, expected.value)
            }
            
            guard !match else { return .success("match given timeline") }
            return .failure(expected: "<\(marble(for: expectedEvents))>",
                            actual: "<\(marble(for: actualEvents))>")
        }
    }
}

public extension Expectation where Element: Equatable {
    // Expects a testable observer to receive a matching timeline
    func matchTimeline(_ expectedEvents: [Recorded<Event<Element>>]) {
        matchTimeline(expectedEvents, predicate: { $0 == $1 })
    }
}

public extension Expectation {
    /// Expects a testable observer to never receive an event
    ///
    /// This is to match a similar behavior of `Observable.never()`
    func beNever() {
        evaluate { events in
            events.isEmpty ?
                .success("emit ever") :
                .failure(expected: "no events", actual: "\(events.count) events")
        }
    }
    /// Expects a testable obserevr to only recieve a `completed` event.
    ///
    /// This is to macth a similar behavior of `Observabel.empty()`
    func beEmpty() {
        evaluate { events in
            guard events.count == 1,
                  events[0].value.isCompleted else {
                return .failure(expected: "to only complete", actual: "<\(marble(for: events))>")
            }
            return .success("be empty")
        }
    }
}
// MARK: - Marble diagram
extension Event {
    var stringValue: String {
        switch self {
        case let .next(value):
            return "\(value)"
        case .error:
            return "x"
        case .completed:
            return "|"
        }
    }
}

func marble<T>(for events: [Recorded<Event<T>>]) -> String {
    events.map { $0.value.stringValue }.joined(separator: "-")
}
