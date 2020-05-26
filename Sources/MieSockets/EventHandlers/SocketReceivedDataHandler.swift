import Foundation

/// Global handle received data event
public protocol SocketReceivedDataHandler {
    func handle(data: Data) -> Void
}

public class DefaultSocketReceivedDataHandler: SocketReceivedDataHandler {
    public func handle(data: Data) -> Void {
        print("Received data: \(String(decoding: data, as: UTF8.self))")
    }
}
