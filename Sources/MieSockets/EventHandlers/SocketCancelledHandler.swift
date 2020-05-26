/// Global handle cancelled event
public protocol SocketCancelledHandler {
    func handle() -> Void
}

public class DefaultSocketCancelledHandler: SocketCancelledHandler {
    public func handle() -> Void {
        print("Cancelled")
    }
}
