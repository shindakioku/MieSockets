import Foundation

/// General namespace. All you need is here.
public enum MieSockets {
    public typealias RouteUrl = MieSockets.Route.Url
    public typealias RouteNamedParams = MieSockets.Route.NamedParams
    public typealias RouteAssociatedParams = MieSockets.Router.AssociatedParams
    
    public typealias ConnectedHandler = SocketConnectedHandler
    public typealias DisconnectedHandler = SocketDisconnectedHandler
    public typealias ErrorHandler = SocketErrorHandler
    public typealias ReceivedDataHandler = SocketReceivedDataHandler
    public typealias ReconnectHandler = SocketReconnectHandler
    public typealias CancelledHandler = SocketCancelledHandler
}

/// Handler for the route
/// It must be Void cuz you don't need to return any value. You must setting properties (or anything more) in the handler.
public protocol RouteHandler {
    func handle(_ handledRoute: HandledRoute) -> Void
}
