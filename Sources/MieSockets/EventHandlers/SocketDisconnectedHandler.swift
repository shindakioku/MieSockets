/// Global handle disconnecte event
public protocol SocketDisconnectedHandler {
    func handle(reason: String, code: UInt16) -> Void
}

public class DefaultSocketDisconnectedHandler: SocketDisconnectedHandler {
    public func handle(reason: String, code: UInt16) -> Void {
        print("Disconnected for: \(reason) with: \(code)")
    }
}
