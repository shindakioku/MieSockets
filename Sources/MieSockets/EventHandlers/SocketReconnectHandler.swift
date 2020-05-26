/// Global handle reconnect event
public protocol SocketReconnectHandler {
    func handle(status: Bool) -> Void
}

public class DefaultSocketReconnectHandler: SocketReconnectHandler {
    public func handle(status: Bool) -> Void {
        print("Reconnect: \(status)")
    }
}
