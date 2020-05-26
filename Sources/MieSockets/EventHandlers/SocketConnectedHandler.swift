/// Global handle connect event
public protocol SocketConnectedHandler {
    typealias Headers = [String: String]
    
    func handle(headers: Headers) -> Void
}

public class DefaultSocketConnectedHandler: SocketConnectedHandler {
    public func handle(headers: SocketConnectedHandler.Headers) -> Void {
        print("Connected: \(headers)")
    }
}
