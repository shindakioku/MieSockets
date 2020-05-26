import XCTest
import SwiftUI
import ViewInspector
@testable import MieSockets
@testable import Starscream

final class MieSocketsTests: XCTestCase {
    internal var socket: MieSockets.SocketSingleton!
    internal var url: String!
    
    internal var mockedWebSocket: WebSocket!
    internal var mockedEngine: Engine!
    
    override func setUp() {
        super.setUp()
        
        self.url = "http://localhost:3000"
        self.socket = MieSockets.SocketSingleton.shared
        
        class MockedSocket: MieSockets.Socket {
            override func onReceivedData(_ data: Data) -> Void {
                self.receivedDataHandler.handle(data: data)
                
                super.onReceivedData(data)
            }
        }
        self.socket.instance = MockedSocket(url: self.url)
        
        class MockedEngine: Engine {
            func register(delegate: EngineDelegate) {}
            func start(request: URLRequest) {}
            func stop(closeCode: UInt16) {}
            func forceStop() {}
            func write(data: Data, opcode: FrameOpCode, completion: (() -> ())?) {}
            func write(string: String, completion: (() -> ())?) {}
        }
        self.mockedEngine = MockedEngine()
        self.mockedWebSocket = WebSocket(request: URLRequest(url: URL(string: self.url)!), engine: self.mockedEngine)
    }
    
    override func tearDown() {
        super.tearDown()
        
        self.url = nil
        self.socket = nil
        self.mockedWebSocket = nil
        self.mockedEngine = nil
    }
    
    func testCorrectSingletonWorks() {
        XCTAssertEqual(URL(string: self.url)!, self.socket.instance.url)
        XCTAssertEqual(URL(string: self.url)!, MieSockets.SocketSingleton.shared.instance.url)
    }
    
    func testConnectedHandlerWasCalled() {
        class Handler: MieSockets.ConnectedHandler {
            var increment = 0
            
            func handle(headers: Headers) {
                increment += 1
            }
        }
        let handler = Handler()
        
        XCTAssertTrue(handler.increment == 0)
        
        self.socket.instance.connectedHandler = handler
        self.socket.instance.didReceive(
            event: WebSocketEvent.connected([:] as Dictionary<String, String>),
            client: self.mockedWebSocket
        )
        
        XCTAssertTrue(handler.increment == 1)
    }
    
    func testErrorHandlerWasCalled() {
        class Handler: MieSockets.ErrorHandler {
            var increment = 0
            
            func handle(error: Error?) {
                increment += 1
            }
        }
        let handler = Handler()
        
        XCTAssertTrue(handler.increment == 0)
        
        self.socket.instance.errorHandler = handler
        self.socket.instance.didReceive(
            event: WebSocketEvent.error(nil),
            client: self.mockedWebSocket
        )
        
        XCTAssertTrue(handler.increment == 1)
    }
    
    func testDisconnetedHandlerWasCalled() {
        class Handler: MieSockets.DisconnectedHandler {
            var increment = 0
            
            func handle(reason: String, code: UInt16) {
                increment += 1
            }
        }
        let handler = Handler()
        
        XCTAssertTrue(handler.increment == 0)
        
        self.socket.instance.disconnectedHandler = handler
        self.socket.instance.didReceive(
            event: WebSocketEvent.disconnected("", 0),
            client: self.mockedWebSocket
        )
        
        XCTAssertTrue(handler.increment == 1)
    }
    
    func testRouterMatchWithoutAvailableRoute() {
        self.socket.instance.router.add("/") { print($0.rawData) }
        
        self.socket.instance.onReceivedData("_".data(using: .utf8)!)
        
        XCTAssertTrue(true)
    }
    
    func testRouterMatchWithoutRegexp() {
        var incremented = 0
        
        self.socket.instance.router.add("/", []) { _ in
            incremented += 1
        }
        self.socket.instance.onReceivedData(eventAndDataToJson("/", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("messages", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("users", "_"))
        
        XCTAssertTrue(incremented == 1)
    }
    
    func testRouterMatchWithRegexp() {
        var incrementedFirst = 0
        var incrementedSecond = 0
        
        self.socket.instance.router.add("/[0-9]$", []) { _ in
            incrementedFirst = 1
        }
        self.socket.instance.router.add("/[0-9]+$", []) { _ in
            incrementedSecond = 2
        }
        self.socket.instance.onReceivedData(eventAndDataToJson("/", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("/messages", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("/users", "_"))
        
        self.socket.instance.onReceivedData(eventAndDataToJson("/1", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("/123", "_"))
        self.socket.instance.onReceivedData(eventAndDataToJson("/q", "_"))
        
        XCTAssertTrue(incrementedFirst == 1)
        XCTAssertTrue(incrementedSecond == 2)
    }
    
    func testRouterWithoutRegexpAndWithCustomHydrator() {
        var incremented = 0
        class CustomHydrator: ReceivedDataHydrator {
            public func hydrate(_ data: Data) -> HydratedData? {
                if let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let event = json["route"] as? MieSockets.RouteUrl {
                        return (url: event, rawData: data)
                    }
                }
                
                return nil
            }
        }
        self.socket.instance.hydrator = CustomHydrator()
        
        self.socket.instance.router.add("/", []) { _ in
            incremented += 1
        }
        self.socket.instance.onReceivedData(eventAndDataToJson("/", "_", eventKeyName: "route"))
        self.socket.instance.onReceivedData(eventAndDataToJson("messages", "_", eventKeyName: "route"))
        self.socket.instance.onReceivedData(eventAndDataToJson("users", "_", eventKeyName: "route"))
        
        XCTAssertTrue(incremented == 1)
    }
    
    func testRouterWrapper() {
        var sut = FooView(self.socket)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertEqual(try! view.actualView().inspect().text().string()!, "Do action")
            try! view.actualView().doAction()
            XCTAssertEqual(try! view.actualView().inspect().text().string()!, "title from server!")
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    private func eventAndDataToJson(_ event: String, _ data: String, eventKeyName: String = "event") -> Data {
        "{\"\(eventKeyName)\": \"\(event)\", \"data\": \"\(data)\"}".data(using: .utf8)!
    }
    
    static var allTests = [
        ("testCorrectSingletonWorks", testCorrectSingletonWorks),
        ("testConnectedHandlerWasCalled", testConnectedHandlerWasCalled),
        ("testErrorHandlerWasCalled", testErrorHandlerWasCalled),
        ("testDisconnetedHandlerWasCalled", testDisconnetedHandlerWasCalled),
        ("testRouterMatchWithoutAvailableRoute", testRouterMatchWithoutAvailableRoute),
        ("testRouterMatchWithoutRegexp", testRouterMatchWithoutRegexp),
        ("testRouterMatchWithRegexp", testRouterMatchWithRegexp),
        ("testRouterWithoutRegexpAndWithCustomHydrator", testRouterWithoutRegexpAndWithCustomHydrator),
        ("testRouterWrapper", testRouterWrapper),
    ]
}

struct FooDecodable: Decodable {
    public var title: String
}
class FooObservable: ObservableObject {
    @MieSockets.RouterWrapperWithDecodable(url: "/", decodeAs: FooDecodable.self) var foo: FooDecodable?
}
struct FooView: View {
    @ObservedObject public var fooObservable = FooObservable()
    var socket: MieSockets.SocketSingleton
    
    internal var didAppear: ((Self) -> Void)?
    
    init(_ socket: MieSockets.SocketSingleton) {
        self.socket = socket
    }
    
    var body: some View {
        Text(self.fooObservable.foo?.title ?? "Do action")
            .onAppear { self.didAppear?(self) }
    }
    
    public func doAction() -> Void {
        self.socket.instance.onReceivedData(
            "{\"event\": \"/\", \"title\": \"title from server!\"}".data(using: .utf8)!
        )
    }
}
extension FooView: Inspectable { }
