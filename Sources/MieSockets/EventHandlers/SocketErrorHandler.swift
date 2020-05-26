import Foundation

/// Global handle error event
public protocol SocketErrorHandler {
    func handle(error: Error?) -> Void
}

public class DefaultSocketErrorHandler: SocketErrorHandler {
    public func handle(error: Error?) -> Void {
        guard let error = error else { return print("Error.") }
        
        print("Error: \(error)")
    }
}
