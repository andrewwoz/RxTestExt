import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxTestExt
@testable import Example

struct TestError: Swift.Error, Equatable, CustomDebugStringConvertible {
    let message: String
    init(_ message: String = "") {
        self.message = message
    }
    public static func == (lhs: TestError, rhs: TestError) -> Bool {
        return lhs.message == rhs.message
    }

    var debugDescription: String {
        return "Error(\(message))"
    }
}

class ExampleTests: XCTestCase {

    var viewModel: ViewModel!
    var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        viewModel = ViewModel()
        scheduler = TestScheduler(initialClock: 0)
    }

    func testRecordingAllEvents() {
        let events = [Recorded.next(10, "alpha"), Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        XCTAssertEqual(source.events, events)
    }

    func testRecordingAllEventsPublishRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        XCTAssertEqual(source.events, events)
    }

    func testRecordingAllEventsBehaviorRelay() {
        let events = [Recorded.next(10, "alpha")]

        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind(events, to: viewModel.behaviorRelayInput)
        scheduler.start()
        XCTAssertEqual(source.events, [Recorded.next(0, "start")] + events)
    }

    func testSentNextEvent() {
        let events = [Recorded.next(10, "alpha"), Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).next()
        assert(source).next(at: 10)
        assert(source).next(times: 1)

        assert(source).next(at: 0, equal: "alpha")
    }

    func testSentNextEventPublishRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).next()
        assert(source).next(at: 10)
        assert(source).next(times: 1)

        assert(source).next(at: 0, equal: "alpha")
    }

    func testSentNextEventBehaviorRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind(events, to: viewModel.behaviorRelayInput)
        scheduler.start()
        assert(source).next()
        assert(source).next(at: 10)
        assert(source).next(times: 2)

        assert(source).next(at: 0, equal: "start")
        assert(source).next(at: 1, equal: "alpha")
    }

    func testNextEventsHelpers() {
        let events = [Recorded.next(10, "alpha"), Recorded.next(12, "bravo"), Recorded.completed(15)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source) == "alpha"
        assert(source).firstNext(equal: "alpha")
        assert(source).lastNext(equal: "bravo")
    }

    func testNextEventsHelpersPublishRelay() {
        let events = [Recorded.next(10, "alpha"), Recorded.next(12, "bravo")]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source) == "alpha"
        assert(source).firstNext(equal: "alpha")
        assert(source).lastNext(equal: "bravo")
    }

    func testNextEventsHelpersBehaviorRelay() {
        let events = [Recorded.next(10, "alpha"), Recorded.next(12, "bravo")]
        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind(events, to: viewModel.behaviorRelayInput)
        scheduler.start()
        assert(source) == "start"
        assert(source).firstNext(equal: "start")
        assert(source).lastNext(equal: "bravo")
    }

    func testNotSentNext() {
        let events: [Recorded<Event<String>>] = [Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).not.next()
    }

    func testNotSentNextPublishRelay() {
        let events: [Recorded<Event<String>>] = [Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).not.next()
    }

    func testErrorEvent() {
        let events = [Recorded.next(10, "alpha"), Recorded.error(20, TestError())]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).error()
        assert(source).error(at: 20)
        assert(source).error(after: 1)
        assert(source).error(with: TestError.self)
        assert(source).error(with: TestError())
    }

    func testNotErrorEvent() {
        let events = [Recorded.next(10, "alpha"), Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).not.error()
    }

    func testNotErrorEventPublishRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).not.error()
    }

    func testNotErrorEventBehaviorRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind(events, to: viewModel.behaviorRelayInput)
        scheduler.start()
        assert(source).not.error()
    }

    func testComplete() {
        let events = [Recorded.next(10, "alpha"), Recorded.completed(10)]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).complete()
        assert(source).complete(at: 10)
        assert(source).complete(after: 1)
    }

    func testNotComplete() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind(events, to: viewModel.input)
        scheduler.start()
        assert(source).not.complete()
    }

    func testNotCompletePublishRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind(events, to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).not.complete()
    }

    func testNotCompleteBehaviorRelay() {
        let events = [Recorded.next(10, "alpha")]
        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind(events, to: viewModel.behaviorRelayInput)
        scheduler.start()
        assert(source).not.complete()
    }

    func testNever() {
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind([], to: viewModel.input)
        scheduler.start()
        assert(source).never()
    }

    func testNeverPublishRelay() {
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind([], to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).never()
    }

    func testEmpty() {
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind([Recorded.completed(10)], to: viewModel.input)
        scheduler.start()
        assert(source).empty()
    }

    func testJust() {
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind([Recorded.next(10, "alpha"), Recorded.completed(10)], to: viewModel.input)
        scheduler.start()
        assert(source).just("alpha")
    }

    func testMatchFirstNext() {
        let source = scheduler.record(source: viewModel.elements)
        scheduler.bind([Recorded.next(10, "alpha"), Recorded.completed(10)], to: viewModel.input)
        scheduler.start()
        assert(source).firstNext {
            (!($0?.isEmpty ?? false), "be empty")
        }
    }

    func testMatchFirstNextPublishRelay() {
        let source = scheduler.record(source: viewModel.publishRelayElements)
        scheduler.bind([Recorded.next(10, "alpha"), Recorded.completed(10)], to: viewModel.publishRelayInput)
        scheduler.start()
        assert(source).firstNext {
            (!($0?.isEmpty ?? false), "be empty")
        }
    }

    func testMatchFirstNextBehaviorRelay() {
        let source = scheduler.record(source: viewModel.behaviorRelayElements)
        scheduler.bind([Recorded.next(10, "alpha"), Recorded.completed(10)], to: viewModel.behaviorRelayInput)
        scheduler.start()
        assert(source).firstNext {
            (!($0?.isEmpty ?? false), "be empty")
        }
    }

    override func tearDown() {
        viewModel = nil
        scheduler = nil
        super.tearDown()
    }
}
